# Google Sheets Weather Dashboard
This is a weather app created entirely within Google Sheets. Why? Well, because we can! Not to mention you can make spreadsheets look however you want so it's your own customizable weather app! Want a chart that doesn't exist? Just create one!

## Installation and Usage
This project requires several steps to get it up and running. 
1. Firstly, make a copy of [the template spreadsheet](https://docs.google.com/spreadsheets/d/1GiUcfSWQMCAxjBuimgX5b03_4uphjIClsd7G2R2KFRM/edit?pli=1&gid=0#gid=0) and save it somewhere in your Google Drive.
2. Clone the repo, run `npm install`, and all that.
3. Make sure you have [Clasp](https://github.com/google/clasp) set up and are logged in. Follow their instructions to link your `dist/` directory in your clone to a script project in your copy of the template spreadsheet.
4. Run `npm run build` to upload this script.
5. Use the spreadsheet! It'll automatically load the ZIP you input on launch, and you can always enter a new ZIP and click update to get new weather.

## External APIs
This relies on [Zippopotam.us](https://zippopotam.us) and [Open-Meteo](https://open-meteo.com). Thanks to the maintainers of these services!

## License
This project is licensed under the [MIT License](LICENSE).
