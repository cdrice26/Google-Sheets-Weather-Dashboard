let decodeStringProperty = (data: option<Js.Json.t>, property: string): string => {
  switch data {
  | None => ""
  | Some(json) =>
    json
    ->Js.Json.decodeObject
    ->Belt.Option.flatMap(obj => obj->Js.Dict.get(property))
    ->Belt.Option.flatMap(Js.Json.decodeString)
    ->Belt.Option.getWithDefault("")
  }
}

let decodeStringPropertyAsFloat = (data: option<Js.Json.t>, property: string): float => {
  data
  ->decodeStringProperty(property)
  ->Belt.Float.fromString
  ->Belt.Option.getWithDefault(0.0)
}

let decodeNumberProperty = (obj: Js.Dict.t<'a>, property: string) =>
  obj
  ->Js.Dict.get(property)
  ->Belt.Option.flatMap(Js.Json.decodeNumber)
  ->Belt.Option.getWithDefault(0.0)

let decodeNumberArrayProperty = (obj: Js.Dict.t<'a>, property: string) =>
  obj
  ->Js.Dict.get(property)
  ->Belt.Option.flatMap(Js.Json.decodeArray)
  ->Belt.Option.map(vals =>
    vals->Array.map(t => t->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
  )
  ->Belt.Option.getWithDefault([])

let decodeStringArrayPropertyAsDates = (obj: Js.Dict.t<'a>, property: string) =>
  obj
  ->Js.Dict.get(property)
  ->Belt.Option.flatMap(Js.Json.decodeArray)
  ->Belt.Option.map(dates =>
    dates->Array.map(d =>
      d
      ->Js.Json.decodeString
      ->Belt.Option.map(Js.Date.fromString)
      ->Belt.Option.getWithDefault(Js.Date.make())
    )
  )
  ->Belt.Option.getWithDefault([])

let decodeLocationResponse = (data: Js.Json.t): APIResponses.Location.location => {
  // Use Js.Json.Decode to safely extract values
  try {
    let places =
      data
      ->Js.Json.decodeObject
      ->Belt.Option.flatMap(obj => obj->Js.Dict.get("places"))
      ->Belt.Option.flatMap(Js.Json.decodeArray)
      ->Belt.Option.getWithDefault([])

    // If places is empty, return default location
    if Array.length(places) == 0 {
      {
        latitude: 0.0,
        longitude: 0.0,
        placeName: "",
      }
    } else {
      // Try to decode the first place
      let firstPlace = places[0]

      // Safely extract latitude, longitude, and place name
      let latitude = firstPlace->decodeStringPropertyAsFloat("latitude")
      let longitude = firstPlace->decodeStringPropertyAsFloat("longitude")
      let placeName = firstPlace->decodeStringProperty("place name")

      {
        latitude,
        longitude,
        placeName,
      }
    }
  } catch {
  | _ => {
      latitude: 0.0,
      longitude: 0.0,
      placeName: "",
    }
  }
}

let decodeWeatherResponse = (data: Js.Json.t): APIResponses.Weather.weatherResponse => {
  try {
    let current: APIResponses.Weather.currentWeather =
      data
      ->Js.Json.decodeObject
      ->Belt.Option.flatMap(obj => obj->Js.Dict.get("current"))
      ->Belt.Option.flatMap(Js.Json.decodeObject)
      ->Belt.Option.map(currentObj => {
        APIResponses.Weather.temperature: currentObj->decodeNumberProperty("temperature_2m"),
        APIResponses.Weather.relativeHumidity: currentObj->decodeNumberProperty(
          "relative_humidity_2m",
        ),
        APIResponses.Weather.apparentTemperature: currentObj->decodeNumberProperty(
          "apparent_temperature",
        ),
        APIResponses.Weather.precipitation: currentObj->decodeNumberProperty("precipitation"),
      })
      ->Belt.Option.getWithDefault({
        temperature: 0.0,
        relativeHumidity: 0.0,
        apparentTemperature: 0.0,
        precipitation: 0.0,
      })

    let hourly =
      data
      ->Js.Json.decodeObject
      ->Belt.Option.flatMap(obj => obj->Js.Dict.get("hourly"))
      ->Belt.Option.flatMap(Js.Json.decodeObject)
      ->Belt.Option.map(hourlyObj => {
        APIResponses.Weather.times: hourlyObj->decodeStringArrayPropertyAsDates("time"),
        APIResponses.Weather.temperatures: hourlyObj->decodeNumberArrayProperty("temperature_2m"),
        APIResponses.Weather.relativeHumidities: hourlyObj->decodeNumberArrayProperty(
          "relative_humidity_2m",
        ),
        APIResponses.Weather.apparentTemperatures: hourlyObj->decodeNumberArrayProperty(
          "apparent_temperature",
        ),
        APIResponses.Weather.precipitationProbabilities: hourlyObj->decodeNumberArrayProperty(
          "precipitation_probability",
        ),
        APIResponses.Weather.precipitations: hourlyObj->decodeNumberArrayProperty("precipitation"),
        APIResponses.Weather.windSpeeds: hourlyObj->decodeNumberArrayProperty("wind_speed_10m"),
        APIResponses.Weather.windGusts: hourlyObj->decodeNumberArrayProperty("wind_gusts_10m"),
      })
      ->Belt.Option.getWithDefault({
        times: [],
        temperatures: [],
        relativeHumidities: [],
        apparentTemperatures: [],
        precipitationProbabilities: [],
        precipitations: [],
        windSpeeds: [],
        windGusts: [],
      })

    let daily =
      data
      ->Js.Json.decodeObject
      ->Belt.Option.flatMap(obj => obj->Js.Dict.get("daily"))
      ->Belt.Option.flatMap(Js.Json.decodeObject)
      ->Belt.Option.map(dailyObj => {
        APIResponses.Weather.times: dailyObj->decodeStringArrayPropertyAsDates("time"),
        APIResponses.Weather.maxTemperatures: dailyObj->decodeNumberArrayProperty(
          "temperature_2m_max",
        ),
        APIResponses.Weather.minTemperatures: dailyObj->decodeNumberArrayProperty(
          "temperature_2m_min",
        ),
        APIResponses.Weather.maxApparentTemperatures: dailyObj->decodeNumberArrayProperty(
          "apparent_temperature_max",
        ),
        APIResponses.Weather.minApparentTemperatures: dailyObj->decodeNumberArrayProperty(
          "apparent_temperature_min",
        ),
        APIResponses.Weather.precipitationSums: dailyObj->decodeNumberArrayProperty(
          "precipitation_sum",
        ),
        APIResponses.Weather.maxWindSpeeds: dailyObj->decodeNumberArrayProperty(
          "wind_speed_10m_max",
        ),
      })
      ->Belt.Option.getWithDefault({
        times: [],
        maxTemperatures: [],
        minTemperatures: [],
        maxApparentTemperatures: [],
        minApparentTemperatures: [],
        precipitationSums: [],
        maxWindSpeeds: [],
      })

    {
      current,
      hourly,
      daily,
    }
  } catch {
  | _ => {
      current: {
        temperature: 0.0,
        relativeHumidity: 0.0,
        apparentTemperature: 0.0,
        precipitation: 0.0,
      },
      hourly: {
        times: [],
        temperatures: [],
        relativeHumidities: [],
        apparentTemperatures: [],
        precipitationProbabilities: [],
        precipitations: [],
        windSpeeds: [],
        windGusts: [],
      },
      daily: {
        times: [],
        maxTemperatures: [],
        minTemperatures: [],
        maxApparentTemperatures: [],
        minApparentTemperatures: [],
        precipitationSums: [],
        maxWindSpeeds: [],
      },
    }
  }
}
