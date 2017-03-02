# OneMikeAlpha

A website that ingests, analyzes, and displays telemetry from N171MA.

## Getting Started

Clone the Git repository and follow the steps below to get started using the
website.

### Dependency Installation

1. Install the following dependencies: PostgreSQL, PostGIS, TimescaleDB, Redis,
   and Yarn. On macOS, you can install Homebrew and then run `brew bundle` to
   install these dependencies.
2. Install Ruby 3.0.1 and the following gems: `bundler`, `foreman`, and
   `mailcatcher` (optional). These gems are not in the Gemfile because they are
   not project-level dependencies.
3. Run `bundle install` to install all required Ruby gems.
4. Run `createuser 1ma` to create the PostgreSQL user, and
   `createdb -O 1ma 1ma_development` to create the development database.

### Configuration

1. Edit the `config/database.yml` file. Set the `superuser.username` value to
   your database's root user name. (For Homebrew installations of PostgreSQL,
   this is the same as your account username.)
2. Edit the `config/environments/common/psql.yml` file. Set the location of the
   two binaries (installed with PostgreSQL and PostGIS).
3. Edit the `db/local_import.rb` file. Under the `options` hash, change the path
   to your local copy of the Project Chute Dropbox directory, if necessary. 

### Importing Flight Data

#### 1. Seed the Development Database

Run `rails db:seed` to seed the development database. This will download and
import a) an FAA airport database, b) an ICAO airport database, and c) a shapes
file with the geographic shapes of all timezones. Importing this data into the
database takes approximately 10 minutes on a fast machine.

#### 2. Import Flight Data from the Project Chute Dropbox

Ensure you have the "R9 Data Logs" Dropbox directory available in your local
disk. View the `db/local_import.rb` file, which is used to do the import from
the Dropbox directory. Familiarize yourself with the command-line options.

You have a couple of different ways you can import these files, and you can mix
and match between all of the below techniques:

##### 2(a)(1). Attended Import

Run the `db/local_import.rb` script. The script will prompt you for an email and
a password for the new development account.

``` sh
rails runner db/local_import.rb
```

##### 2(a)(2). Unattended Import

For an unattended import, be sure to set the `-e` and `-p` options when running
the script:

``` sh
rails runner db/local_import.rb -- -etest@example.com -psecret123
```

##### 2(b)(1). Parallelized Import

The script will complete quickly, because all it does is create the Import
objects for each CSV file. The actual importing is done by Sidekiq. Run
`foreman start` to start the full web stack, including Sidekiq. Workers will
begin processing the CSV files. You can edit `config/sidekiq.yml` to adjust the
concurrency.

You can monitor import progress by visiting http://localhost:5000/sidekiq.

##### 2(b)(2). Inline Import

To import the CSV files in serial in the `rails runner` process, without needing
Sidekiq, include the `-i` flag:

``` sh
rails runner db/local_import.rb -i
```

The import will run slower, but won't destroy your user experience, and is less
likely to break due to Sidekiq weirdness or whatever.

##### 2(c)(1). Importing All Files

By default, the `local_import.rb` script finds and imports all CSV files within
the "R9 Data Logs" directory. This represents 4+ years of N171MA flying history.
Even on a fast machine, importing all this data can take 48+ hours.

##### 2(c)(2). Importing a Subset of Files

To speed up the import process, you can choose to only import a smaller subset
of the R9 data logs (e.g., the most recent download). Do this by specifying a
subdirectory using the `-P` switch:

``` sh
rails runner db/local_import.rb -P/Users/tmorgan/Dropbox/Project\ Chute/N171MA/Operation\ Records/R9\ Data\ Logs/2021-04-30
```

### Backup and Restore

Because this websites uses TimescaleDB, you must follow the instructions at
https://docs.timescale.com/timescaledb/latest/how-to-guides/backup-and-restore/pg-dump-and-restore/#logical-backups-with-pg-dump-and-pg-restore
to properly back up the database or restore from a backup.

### Running the Website

Once the import is complete, run `foreman start` to start the web stack.
Navigate to http://localhost:5000 in a web browser. Log in as the user
credentials you gave to the `local_import.rb` script.

## TODO

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
