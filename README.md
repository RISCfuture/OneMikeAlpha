# TODO

* Frontend
  * flights/index
    * Awards on record-holding flights
    * Cautions on exceedance flights (reg=gray, mfr=yellow/red)
    * Expand filter to search airport name and human-readable date
      * Add magnifying glass icon back to filter
  * flights/show
    * Planview
      * Underlay sectionals/IFR
    * Charts
      * SQL->LVK squirrely chart
      * Figure out why jumps to top on reposition
      * Fade out/roll up charts when removed
      * Drag an area to zoom
        * Zooming in chart zooms in map
      * x-axis shows local/zulu/elapsed time
    * Awards
      * Examples
        * Highest ground speed, altitude
        * Furthest north/south
        * Furthest from SQL
        * Longest leg (by distance, by time, by distance flown)
        * Highest landing, shortest runway, longest runway
        * Best average MPG / most efficient trip
        * Coldest/warmest?
      * Annotate tab with # of awards
    * Exceedances
      * Regulatory and manufacturer exceedances
      * Only shown when logged in
      * Annotate tab with # of exceedances
  * NEW: awards/index (?)
    * Per-aircraft list of all awards
  * Finalize design
  * Add error state for each vuex module
    * Telemetry, boundaries
    * Route
  * Moar postcss variables
  * Edit airplane lightbox doesn't automatically update
  * Uploading and upload progress
  * responsive/mobile-friendly
  * dark mode lol
  * i18n vue HTML content
  * "Help us add it" page
* Backend
  * Store additional info in flights to support awards
    * HABTM to airports/runways
  * Write awards generation
  * Write exceedances generation
  * Don't process files that have been already uploaded
  * Convert raw SQL updaters to ARel update plans
