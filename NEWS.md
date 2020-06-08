## shinySearchbar 1.0.0 - 5/14/20
* `searchbar()` as a `ui` function to include the searchbar widget
* `updateMarkOptions()` as a `server` function to update the mark.js options for an initialized searchbar widget
* Default mark.js options included internally as the `configurator` list (accessible with `shinySearchbar:::configurator`)
  * Passed to JavaScript in JSON format using `jsonlite::toJSON()`
* Designed around mark.js v8.1.1, including *all* API options except for the callback functions: `each`, `filter`, `noMatch`, and `done` (used interally)
