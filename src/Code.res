@scope("UrlFetchApp") @val external fetch: string => string = "fetch"
@scope("JSON") @val external parseJSON: string => Js.Json.t = "parse"
@scope("SpreadsheetApp") @val
external getActiveSpreadsheet: unit => GoogleAppsScript.Spreadsheet.spreadsheet =
  "getActiveSpreadsheet"
@scope("ScriptApp") @val
external newTrigger: string => GoogleAppsScript.Triggers.trigger = "newTrigger"

let getCoords = zip => {
  let resp = fetch(`https://api.zippopotam.us/us/${zip}`)
  let data = parseJSON(resp)
  Decode.decodeLocationResponse(data)
}

let getWeather = (latitude, longitude) => {
  let latitude = Js.Float.toString(latitude)
  let longitude = Js.Float.toString(longitude)
  let resp = fetch(
    `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,precipitation,wind_speed_10m,wind_gusts_10m&daily=temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,precipitation_sum,wind_speed_10m_max&timezone=auto&forecast_days=14&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch`,
  )
  let data = parseJSON(resp)
  Decode.decodeWeatherResponse(data)
}

let setColumn = (sheet: GoogleAppsScript.Sheet.sheet, colIndex, parameter) => {
  switch parameter {
  | None =>
    // If parameter is null, clear the column
    sheet
    ->GoogleAppsScript.Sheet.getRange(GoogleAppsScript.Sheet.Ints(2, colIndex, 1000, 1))
    ->GoogleAppsScript.Range.clear
  | Some(values) if Array.length(values) == 0 =>
    // If parameter is an empty array, clear the column
    sheet
    ->GoogleAppsScript.Sheet.getRange(GoogleAppsScript.Sheet.Ints(2, colIndex, 1000, 1))
    ->GoogleAppsScript.Range.clear
  | Some(values) => {
      // Convert values to a 2D array of values
      let formattedValues = values->Array.map(val =>
        switch val {
        | #string(s) => [GoogleAppsScript.Range.String(s)]
        | #int(i) => [GoogleAppsScript.Range.Int(i)]
        | #float(f) => [GoogleAppsScript.Range.Float(f)]
        | #date(d) => [GoogleAppsScript.Range.Date(d)]
        | _ => [GoogleAppsScript.Range.String(Js.String2.make(val))]
        }
      )
      sheet
      ->GoogleAppsScript.Sheet.getRange(
        GoogleAppsScript.Sheet.Ints(2, colIndex, formattedValues->Array.length, 1),
      )
      ->GoogleAppsScript.Range.setValues(formattedValues)
    }
  }
}

let updateCurrentData = (
  current: APIResponses.Weather.currentWeather,
  sheet: GoogleAppsScript.Sheet.sheet,
) => {
  sheet
  ->GoogleAppsScript.Sheet.getRange(GoogleAppsScript.Sheet.Str("D10"))
  ->GoogleAppsScript.Range.setValue(
    GoogleAppsScript.Range.String(
      string_of_int(Js.Math.round(current.temperature)->Belt.Float.toInt) ++ "\u00B0" ++ "F",
    ),
  )
  sheet
  ->GoogleAppsScript.Sheet.getRange(GoogleAppsScript.Sheet.Str("D12"))
  ->GoogleAppsScript.Range.setValue(
    GoogleAppsScript.Range.String(
      string_of_int(Js.Math.round(current.apparentTemperature)->Belt.Float.toInt) ++
      "\u00B0" ++ "F",
    ),
  )
  sheet
  ->GoogleAppsScript.Sheet.getRange(GoogleAppsScript.Sheet.Str("D14"))
  ->GoogleAppsScript.Range.setValue(
    GoogleAppsScript.Range.String(Js.Float.toString(current.precipitation) ++ " in"),
  )
  sheet
  ->GoogleAppsScript.Sheet.getRange(GoogleAppsScript.Sheet.Str("D16"))
  ->GoogleAppsScript.Range.setValue(
    GoogleAppsScript.Range.String(Js.Float.toString(current.relativeHumidity) ++ " %"),
  )
}

let updateHourlyData = (
  hourly: APIResponses.Weather.hourlyWeather,
  sheet: GoogleAppsScript.Sheet.sheet,
) => {
  // Hourly Data
  setColumn(sheet, 1, Some(hourly.times->Belt.Array.map(time => #date(time))))
  setColumn(sheet, 2, Some(hourly.temperatures->Belt.Array.map(temp => #float(temp))))
  setColumn(sheet, 3, Some(hourly.apparentTemperatures->Belt.Array.map(temp => #float(temp))))
  setColumn(sheet, 4, Some(hourly.precipitationProbabilities->Belt.Array.map(prob => #float(prob))))
  setColumn(sheet, 5, Some(hourly.precipitations->Belt.Array.map(prob => #float(prob))))
  setColumn(sheet, 6, Some(hourly.relativeHumidities->Belt.Array.map(prob => #float(prob))))
  setColumn(sheet, 7, Some(hourly.windSpeeds->Belt.Array.map(prob => #float(prob))))
  setColumn(sheet, 8, Some(hourly.windGusts->Belt.Array.map(prob => #float(prob))))

  // Delete rows that are in the past
  let range = sheet->GoogleAppsScript.Sheet.getDataRange
  let hourlyData = range->GoogleAppsScript.Range.getValues
  hourlyData->Array.forEachWithIndex((row: array<'a>, index) => {
    switch row[0] {
    | dateValue
      if switch dateValue {
      | Some(s) => Js.Date.fromString(s)
      | None => Js.Date.make()
      }->Js.Date.getTime < Js.Date.make()->Js.Date.getTime =>
      // Delete row if date is in the past (1-indexed, so add 1 to index)
      sheet->GoogleAppsScript.Sheet.deleteRow(index + 2)
    | _ => ()
    }
  })
}

let updateDailyData = (
  daily: APIResponses.Weather.dailyWeather,
  sheet: GoogleAppsScript.Sheet.sheet,
) => {
  setColumn(sheet, 1, Some(daily.times->Belt.Array.map(time => #date(time))))
  setColumn(sheet, 2, Some(daily.maxTemperatures->Belt.Array.map(temp => #float(temp))))
  setColumn(sheet, 3, Some(daily.minTemperatures->Belt.Array.map(temp => #float(temp))))
  setColumn(sheet, 4, Some(daily.maxApparentTemperatures->Belt.Array.map(temp => #float(temp))))
  setColumn(sheet, 5, Some(daily.minApparentTemperatures->Belt.Array.map(temp => #float(temp))))
  setColumn(sheet, 6, Some(daily.precipitationSums->Belt.Array.map(temp => #float(temp))))
  setColumn(sheet, 7, Some(daily.maxWindSpeeds->Belt.Array.map(temp => #float(temp))))
}

let updateWeather = () => {
  let workbook = getActiveSpreadsheet()
  let interface = workbook->GoogleAppsScript.Spreadsheet.getSheetByName("interface")
  let hourlySheet = workbook->GoogleAppsScript.Spreadsheet.getSheetByName("hourly")
  let dailySheet = workbook->GoogleAppsScript.Spreadsheet.getSheetByName("daily")
  let rawZip =
    interface
    ->GoogleAppsScript.Sheet.getRange(Str("D2"))
    ->GoogleAppsScript.Range.getValue
  let zip = string_of_int(
    switch rawZip {
    | GoogleAppsScript.Range.String(s) => int_of_string(s)
    | GoogleAppsScript.Range.Int(i) => i
    | _ => 00000
    },
  )
  let {latitude, longitude, placeName} = getCoords(zip)
  interface
  ->GoogleAppsScript.Sheet.getRange(Str("B6"))
  ->GoogleAppsScript.Range.setValue(GoogleAppsScript.Range.String(`Weather for ${placeName}`))
  let {current, hourly, daily} = getWeather(latitude, longitude)
  updateCurrentData(current, interface)
  updateHourlyData(hourly, hourlySheet)
  updateDailyData(daily, dailySheet)
}

let onClick = () => updateWeather()

let createOnOpenTrigger = () => {
  let spreadsheet = getActiveSpreadsheet()
  newTrigger("updateWeather")
  ->GoogleAppsScript.Triggers.forSpreadsheet(spreadsheet)
  ->GoogleAppsScript.Triggers.onOpen
  ->GoogleAppsScript.Triggers.create
}
