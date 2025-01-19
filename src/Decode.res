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
      let latitude = switch firstPlace {
      | None => 0.0
      | Some(place) =>
        place
        ->Js.Json.decodeObject
        ->Belt.Option.flatMap(obj => obj->Js.Dict.get("latitude"))
        ->Belt.Option.flatMap(Js.Json.decodeNumber)
        ->Belt.Option.getWithDefault(0.0)
      }
      let longitude = switch firstPlace {
      | None => 0.0
      | Some(place) =>
        place
        ->Js.Json.decodeObject
        ->Belt.Option.flatMap(obj => obj->Js.Dict.get("longitude"))
        ->Belt.Option.flatMap(Js.Json.decodeNumber)
        ->Belt.Option.getWithDefault(0.0)
      }

      let placeName = switch firstPlace {
      | None => ""
      | Some(place) =>
        place
        ->Js.Json.decodeObject
        ->Belt.Option.flatMap(obj => obj->Js.Dict.get("place name"))
        ->Belt.Option.flatMap(Js.Json.decodeString)
        ->Belt.Option.getWithDefault("")
      }

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
        APIResponses.Weather.temperature: currentObj
        ->Js.Dict.get("temperature_2m")
        ->Belt.Option.flatMap(Js.Json.decodeNumber)
        ->Belt.Option.getWithDefault(0.0),
        APIResponses.Weather.relativeHumidity: currentObj
        ->Js.Dict.get("relative_humidity_2m")
        ->Belt.Option.flatMap(Js.Json.decodeNumber)
        ->Belt.Option.getWithDefault(0.0),
        APIResponses.Weather.apparentTemperature: currentObj
        ->Js.Dict.get("apparent_temperature")
        ->Belt.Option.flatMap(Js.Json.decodeNumber)
        ->Belt.Option.getWithDefault(0.0),
        APIResponses.Weather.precipitation: currentObj
        ->Js.Dict.get("precipitation")
        ->Belt.Option.flatMap(Js.Json.decodeNumber)
        ->Belt.Option.getWithDefault(0.0),
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
        APIResponses.Weather.times: hourlyObj
        ->Js.Dict.get("time")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(times =>
          times->Array.map(
            t =>
              t
              ->Js.Json.decodeString
              ->Belt.Option.map(Js.Date.fromString)
              ->Belt.Option.getWithDefault(Js.Date.make()),
          )
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.temperatures: hourlyObj
        ->Js.Dict.get("temperature_2m")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(temps =>
          temps->Array.map(t => t->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.relativeHumidities: hourlyObj
        ->Js.Dict.get("relative_humidity_2m")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(humidities =>
          humidities->Array.map(h => h->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.apparentTemperatures: hourlyObj
        ->Js.Dict.get("apparent_temperature")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(temps =>
          temps->Array.map(t => t->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.precipitationProbabilities: hourlyObj
        ->Js.Dict.get("precipitation_probability")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(probs =>
          probs->Array.map(p => p->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.precipitations: hourlyObj
        ->Js.Dict.get("precipitation")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(precs =>
          precs->Array.map(p => p->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.windSpeeds: hourlyObj
        ->Js.Dict.get("wind_speed_10m")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(speeds =>
          speeds->Array.map(s => s->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.windGusts: hourlyObj
        ->Js.Dict.get("wind_gusts_10m")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(gusts =>
          gusts->Array.map(g => g->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
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
        APIResponses.Weather.times: dailyObj
        ->Js.Dict.get("time")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(times =>
          times->Array.map(
            t =>
              t
              ->Js.Json.decodeString
              ->Belt.Option.map(Js.Date.fromString)
              ->Belt.Option.getWithDefault(Js.Date.make()),
          )
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.maxTemperatures: dailyObj
        ->Js.Dict.get("temperature_2m_max")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(temps =>
          temps->Array.map(t => t->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.minTemperatures: dailyObj
        ->Js.Dict.get("temperature_2m_min")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(temps =>
          temps->Array.map(t => t->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.maxApparentTemperatures: dailyObj
        ->Js.Dict.get("apparent_temperature_max")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(temps =>
          temps->Array.map(t => t->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.minApparentTemperatures: dailyObj
        ->Js.Dict.get("apparent_temperature_min")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(temps =>
          temps->Array.map(t => t->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.precipitationSums: dailyObj
        ->Js.Dict.get("precipitation_sum")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(precs =>
          precs->Array.map(p => p->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
        APIResponses.Weather.maxWindSpeeds: dailyObj
        ->Js.Dict.get("wind_speed_10m_max")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(speeds =>
          speeds->Array.map(s => s->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0))
        )
        ->Belt.Option.getWithDefault([]),
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
