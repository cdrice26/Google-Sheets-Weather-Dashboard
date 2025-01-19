module Range = {
  type range = {}

  type value =
    | String(string)
    | Int(int)
    | Float(float)
    | Date(Js.Date.t)

  @send external getValue': range => 'a = "getValue"

  let getValue = (range): value => {
    let rawValue = getValue'(range)
    switch rawValue {
    | v if Js.typeof(v) == "number" => Js.Math.floor(v) == v ? Int(int_of_float(v)) : Float(v)
    | v if Js.typeof(v) == "string" => String(v)
    | v
      if Js.typeof(v) == "object" &&
        Js.typeof(Js.Nullable.toOption(v)->Belt.Option.map(x => x["getTime"])) == "function" =>
      Date(v)
    | _ => String(Js.String.make(rawValue))
    }
  }

  @send external getValues: range => array<array<string>> = "getValues"

  @send
  external setValue': (range, string) => unit = "setValue"

  @send
  external setValues': (range, array<array<string>>) => unit = "setValues"

  let setValue = (range, value: value) => {
    switch value {
    | String(s) => setValue'(range, s)
    | Int(i) => setValue'(range, string_of_int(i))
    | Float(f) => setValue'(range, Js.Float.toString(f))
    | Date(d) => setValue'(range, d->Js.Date.toLocaleString)
    }
  }

  let setValues = (range, values: array<array<value>>) => {
    let stringValues = values->Array.map(value =>
      Array.map(value, val =>
        switch val {
        | String(s) => s
        | Int(i) => string_of_int(i)
        | Float(f) => Js.Float.toString(f)
        | Date(d) => d->Js.Date.toLocaleString
        }
      )
    )

    setValues'(range, stringValues)
  }

  @send external clear: range => unit = "clear"
}

module Sheet = {
  type sheet = {}

  @send
  external getRange: (sheet, string) => Range.range = "getRange"

  @send external getRangeWithNums: (sheet, int, int, int, int) => Range.range = "getRange"

  type getRangeParam =
    | Ints(int, int, int, int) // This represents the 4-integer version
    | Str(string) // This represents the string version

  let getRange = (sheet, param) => {
    switch param {
    | Ints(a, b, c, d) => sheet->getRangeWithNums(a, b, c, d)
    | Str(s) => sheet->getRange(s)
    }
  }

  @send external getDataRange: sheet => Range.range = "getDataRange"

  @send external deleteRow: (sheet, int) => unit = "deleteRow"
}

module Spreadsheet = {
  type spreadsheet = {}

  @send
  external getSheetByName: (spreadsheet, string) => Sheet.sheet = "getSheetByName"
}

module Triggers = {
  type trigger = {}

  @send external forSpreadsheet: (trigger, Spreadsheet.spreadsheet) => trigger = "forSpreadsheet"
  @send external onOpen: trigger => trigger = "onOpen"
  @send external create: trigger => unit = "create"
}
