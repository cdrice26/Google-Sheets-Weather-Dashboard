/** 
 * Provides type-safe bindings and utilities for working with Google Sheets ranges.
 * Handles conversion between different value types and provides range manipulation methods.
 */
module Range = {
  /** Represents a range in a Google Sheets spreadsheet */
  type range = {}

  /** 
   * Represents different types of values that can be stored in a spreadsheet cell.
   * Supports string, integer, float, and date values with type-safe conversion.
   */
  type value =
    | String(string)
    | Int(int)
    | Float(float)
    | Date(Js.Date.t)

  @send external getValue': range => 'a = "getValue"

  /** 
   * Safely retrieves the value from a range, automatically detecting and converting the type.
   * @param range The range to get the value from
   * @returns A type-safe value representing the cell's contents
   */
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

  /** 
   * Sets the value of a range, automatically converting the value to a string representation.
   * @param range The range to set the value in
   * @param value The value to set, which can be a string, int, float, or date
   */
  let setValue = (range, value: value) => {
    switch value {
    | String(s) => setValue'(range, s)
    | Int(i) => setValue'(range, string_of_int(i))
    | Float(f) => setValue'(range, Js.Float.toString(f))
    | Date(d) => setValue'(range, d->Js.Date.toLocaleString)
    }
  }

  @send
  external setValues': (range, array<array<string>>) => unit = "setValues"

  /** 
   * Sets multiple values in a range, converting each value to its string representation.
   * @param range The range to set values in
   * @param values A 2D array of values to set in the range
   */
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

/** 
 * Provides type-safe bindings and utilities for working with Google Sheets sheets.
 * Offers methods to interact with and manipulate individual sheets within a spreadsheet.
 */
module Sheet = {
  /** Represents a sheet within a Google Spreadsheet */
  type sheet = {}

  @send
  external getRange: (sheet, string) => Range.range = "getRange"

  @send external getRangeWithNums: (sheet, int, int, int, int) => Range.range = "getRange"

  /**
   * Represents the parameters for getting a range in a sheet.
   * Can be either a string cell reference or row/column parameters.
   */
  type getRangeParam =
    | Ints(int, int, int, int) // This represents the 4-integer version
    | Str(string) // This represents the string version

  /** 
   * Flexible method to get a range in a sheet, supporting both string and integer-based range selection.
   * @param sheet The sheet to get the range from
   * @param param Either a string cell reference or row/column parameters
   * @returns A range object representing the selected cells
   */
  let getRange = (sheet, param) => {
    switch param {
    | Ints(a, b, c, d) => sheet->getRangeWithNums(a, b, c, d)
    | Str(s) => sheet->getRange(s)
    }
  }

  @send external getDataRange: sheet => Range.range = "getDataRange"

  @send external deleteRow: (sheet, int) => unit = "deleteRow"
}

/** 
 * Provides type-safe bindings for working with Google Spreadsheets.
 * Offers methods to access and manipulate spreadsheet-level operations.
 */
module Spreadsheet = {
  /** Represents a Google Spreadsheet */
  type spreadsheet = {}

  @send
  external getSheetByName: (spreadsheet, string) => Sheet.sheet = "getSheetByName"
}

/** 
 * Provides type-safe bindings for creating and managing Google Apps Script triggers.
 * Allows setting up automatic actions like running scripts on spreadsheet open.
 */
module Triggers = {
  /** Represents a Google Apps Script trigger */
  type trigger = {}

  @send external forSpreadsheet: (trigger, Spreadsheet.spreadsheet) => trigger = "forSpreadsheet"
  @send external onOpen: trigger => trigger = "onOpen"
  @send external create: trigger => unit = "create"
}
