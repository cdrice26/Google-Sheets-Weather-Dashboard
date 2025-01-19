module Location = {
  /** 
   * Represents a geographical location with coordinates and place name.
   * @property latitude The latitude of the location
   * @property longitude The longitude of the location
   * @property placeName The name of the place at the given coordinates
   */
  type location = {
    latitude: float,
    longitude: float,
    placeName: string,
  }

  /** 
   * Represents the response from a location API, containing an array of possible locations.
   * @property places An array of optional location objects
   */
  type locationResponse = {places: array<option<location>>}
}

module Weather = {
  /** 
   * Represents the current weather conditions.
   * @property temperature The current temperature in Fahrenheit
   * @property relativeHumidity The current relative humidity percentage
   * @property apparentTemperature The "feels like" temperature in Fahrenheit
   * @property precipitation The amount of precipitation in inches
   */
  type currentWeather = {
    temperature: float,
    relativeHumidity: float,
    apparentTemperature: float,
    precipitation: float,
  }

  /** 
   * Represents hourly weather forecast data.
   * @property times Array of timestamps for each hourly forecast
   * @property temperatures Hourly temperature readings
   * @property relativeHumidities Hourly relative humidity percentages
   * @property apparentTemperatures Hourly "feels like" temperatures
   * @property precipitationProbabilities Hourly precipitation probability percentages
   * @property precipitations Hourly precipitation amounts in inches
   * @property windSpeeds Hourly wind speeds in miles per hour
   * @property windGusts Hourly wind gust speeds in miles per hour
   */
  type hourlyWeather = {
    times: array<Js.Date.t>,
    temperatures: array<float>,
    relativeHumidities: array<float>,
    apparentTemperatures: array<float>,
    precipitationProbabilities: array<float>,
    precipitations: array<float>,
    windSpeeds: array<float>,
    windGusts: array<float>,
  }

  /** 
   * Represents daily weather forecast data.
   * @property times Array of timestamps for each daily forecast
   * @property maxTemperatures Daily maximum temperatures
   * @property minTemperatures Daily minimum temperatures
   * @property maxApparentTemperatures Daily maximum "feels like" temperatures
   * @property minApparentTemperatures Daily minimum "feels like" temperatures
   * @property precipitationSums Daily total precipitation amounts
   * @property maxWindSpeeds Daily maximum wind speeds
   */
  type dailyWeather = {
    times: array<Js.Date.t>,
    maxTemperatures: array<float>,
    minTemperatures: array<float>,
    maxApparentTemperatures: array<float>,
    minApparentTemperatures: array<float>,
    precipitationSums: array<float>,
    maxWindSpeeds: array<float>,
  }

  /** 
   * Represents the complete weather response containing current, hourly, and daily forecasts.
   * @property current Current weather conditions
   * @property hourly Hourly weather forecast
   * @property daily Daily weather forecast
   */
  type weatherResponse = {
    current: currentWeather,
    hourly: hourlyWeather,
    daily: dailyWeather,
  }
}
