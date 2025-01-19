module Location = {
  type location = {
    latitude: float,
    longitude: float,
    placeName: string,
  }

  type locationResponse = {places: array<option<location>>}
}

module Weather = {
  type currentWeather = {
    temperature: float,
    relativeHumidity: float,
    apparentTemperature: float,
    precipitation: float,
  }

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

  type dailyWeather = {
    times: array<Js.Date.t>,
    maxTemperatures: array<float>,
    minTemperatures: array<float>,
    maxApparentTemperatures: array<float>,
    minApparentTemperatures: array<float>,
    precipitationSums: array<float>,
    maxWindSpeeds: array<float>,
  }

  type weatherResponse = {
    current: currentWeather,
    hourly: hourlyWeather,
    daily: dailyWeather,
  }
}
