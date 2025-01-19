const getCoords = (zip) => {
  const resp = UrlFetchApp.fetch(`https://api.zippopotam.us/us/${zip}`);
  const data = JSON.parse(resp);
  const place = data.places[0];
  return { 
    latitude: place.latitude,
    longitude: place.longitude,
    placeName: `${place['place name']}, ${place['state abbreviation']}`
  };
};

const getWeather = (latitude, longitude) => {
  const resp = UrlFetchApp.fetch(`https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,precipitation,wind_speed_10m,wind_gusts_10m&daily=temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,precipitation_sum,wind_speed_10m_max&timezone=auto&forecast_days=14&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch`);
  const data = JSON.parse(resp);
  return {
    current: data.current,
    hourly: data.hourly,
    daily: data.daily
  };
};

const setColumn = (sheet, colIndex, parameter) => {
  sheet.getRange(2, colIndex, parameter?.length ?? 0, 1).setValues(parameter.map(val => [val]));
};

const updateWeather = () => {
  const workbook = SpreadsheetApp.getActiveSpreadsheet();
  const interface = workbook.getSheetByName('interface');
  const hourlySheet = workbook.getSheetByName('hourly');
  const dailySheet = workbook.getSheetByName('daily');
  const zip = interface.getRange('D2').getValue().toString();
  const { latitude, longitude, placeName } = getCoords(zip);
  interface.getRange('B6').setValue(`Weather for ${placeName}`);
  const { current, hourly, daily } = getWeather(latitude, longitude);

  // Current Data
  interface.getRange('D10').setValue(Math.round(current?.temperature_2m) + "\u00B0" + "F");
  interface.getRange('D12').setValue(Math.round(current?.apparent_temperature) + "\u00B0" + "F");
  interface.getRange('D14').setValue(current?.precipitation + " in");
  interface.getRange('D16').setValue(current?.relative_humidity_2m + " %");

  // Hourly Data
  setColumn(hourlySheet, 1, hourly?.time.map(val => new Date(val)));
  setColumn(hourlySheet, 2, hourly?.temperature_2m);
  setColumn(hourlySheet, 3, hourly?.apparent_temperature);
  setColumn(hourlySheet, 4, hourly?.precipitation_probability);
  setColumn(hourlySheet, 5, hourly?.precipitation);
  setColumn(hourlySheet, 6, hourly?.relative_humidity_2m);
  setColumn(hourlySheet, 7, hourly?.wind_speed_10m);
  setColumn(hourlySheet, 8, hourly?.wind_gusts_10m);

  // Delete rows that are in the past
  const range = hourlySheet.getDataRange();
  const hourlyData = range.getValues();
  for (let i = hourlyData.length - 1; i >= 0; i--) {
    const dateValue = hourlyData[i][0];
    if (dateValue instanceof Date && dateValue < Date.now())
      hourlySheet.deleteRow(i + 1);
  }
  
  // Daily Data
  setColumn(dailySheet, 1, daily?.time.map(val => new Date(val + "T00:00:00")));
  setColumn(dailySheet, 2, daily?.temperature_2m_max);
  setColumn(dailySheet, 3, daily?.temperature_2m_min);
  setColumn(dailySheet, 4, daily?.apparent_temperature_max);
  setColumn(dailySheet, 5, daily?.apparent_temperature_min);
  setColumn(dailySheet, 6, daily?.precipitation_sum);
  setColumn(dailySheet, 7, daily?.wind_speed_10m_max);
};

const onClick = () => {
  updateWeather();
};

const createOnOpenTrigger = () => {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  ScriptApp.newTrigger('updateWeather')
    .forSpreadsheet(ss)
    .onOpen()
    .create();
};
