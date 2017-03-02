import charts from './charts'
import types from './types'
import aircraft from './aircraft'

export default {
  charts, types, aircraft,

  general: {
    forms: {
      optionalPlaceholder: "optional",
      update: "Update",
      delete: "Delete"
    },
    airport: {
      unknownLID: "???",
      unknown: "unknown"
    },
    flight: {
      arrow: "→"
    }
  },

  date: {
    dateOnlyFilename: 'YYY-MM-DD',
    dateOnlyMedium: 'MMM D YYYY',
    fullLocal: 'MMM D  h:mm A z',
    fullZulu: 'MMM D  HHmm',
    fullZuluFormat: "{date}Z"
  },

  number: {
    flightHours: '0,0.0',
    integer: '0,0'
  },

  components: {
    sessionActions: {
      logIn: "Log In",
      signUp: "Sign Up",
      logOut: "Log Out"
    }
  },

  views: {
    aircraft: {
      form: {
        registration: "Registration",
        name: "Name",
        type: "Type",
        equipment: "Equipment",
        permissionsHeader: "Permissions"
      },
      edit: {
        confirmDelete: "Are you sure you want to delete {aircraft}?",
        deleteFailed: "Couldn’t delete {aircraft}.",
        addPermission: {
          add: "Add",
          failure: {
            noUser: "Couldn’t find user with email {email}.",
            other: "Couldn’t add permissions for {email} to {aircraft}."
          }
        },
        permission: {
          failure: {
            remove: "Couldn’t remove permissions from {email}.",
            edit: "Couldn’t edit permissions for {email}."
          },
          selfRemoveWarn: "You are removing admin privileges from yourself. Once you do this, you will no longer be able to manage permissions for {aircraft}. Are you sure you want to do this?"
        }
      },
      index: {
        addLink: "Add Aircraft"
      },
      new: {
        addButton: "Add Aircraft",
        notSupportedYet: "Don’t see your aircraft or equipment in the list?",
        helpUs: "Help us add it."
      },
      none: {
        logIn: "Log in or sign up to begin",
        choose: "Choose an aircraft",
        clickPlus: "Click the “+” to add an aircraft",
        requestPermission: "Or, request permission someone who’s already added the aircraft"
      }
    },
    flights: {
      index: {
        unknownAircraft: "Unknown aircraft",
        list: {
          importLink: "Import… | One file importing… | {count} files importing…",
          filterPlaceholder: "Airport"
        }
      },
      import: {
        addUpload: "Upload log files",
        addMoreUploads: "Upload more log files",
        upload: {
          multipleFiles: "{name} and {count} more"
        }
      },
      show: {
        unknownFlight: "Unknown flight",
        awards: {
          title: "Awards"
        },
        charts: {
          addChart: "Add chart:",
          showMarkers: "Show markers:",
          title: "Charts"
        },
        exceedances: {
          title: "Exceedances"
        },
        planview: {
          mapStyle: {
            road: "road",
            satellite: "satellite"
          },
          downloadLink: "Download as:"
        },
        stats: {
          rangeValue: "{from} — {to}",
          departureArrival: "Departure — Arrival",
          takeoffLanding: "Takeoff — Landing",
          duration: "Duration",
          directDistance: "Direct Distance",
          distanceFlown: "Distance Flown",
          shareLink: "Share this Flight",
          toggleTimezoneLink: {
            utc: "(show UTC)",
            local: "(show local)"
          },
          sharePrompt: "Copy this URL to share the flight with anyone:"
        }
      },
      none: {
        chooseFlight: "Choose a flight"
      },
      shared: {
        badURL: "Bad share URL"
      },
    },
    session: {
      form: {
        email: "email",
        password: "password",
        passwordConfirmation: "again"
      },
      login: {
        wrongCredentials: "Login or password incorrect.",
        otherError: "Error {error}"
      }
    }
  }
}
