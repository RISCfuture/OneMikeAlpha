import Vue from 'vue'
import Component from 'vue-class-component'
import {Getter} from 'vuex-class'

import {Aircraft, Flight} from 'types'

// const SHARE_TOKEN_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

@Component
export default class CurrentRoute extends Vue {
  @Getter aircraftByID: (ID: string) => Aircraft | null
  @Getter flightByID: (ID: string) => Flight | null

  get currentAircraftID(): string | null {
    return this.$route.params.aircraftID
  }

  get currentFlightID(): string | null {
    return this.$route.params.flightID
  }

  get currentAircraft(): Aircraft | null {
    if (!this.currentAircraftID) return null
    return this.aircraftByID(this.currentAircraftID)
  }

  get currentFlight(): Flight | null {
    if (!this.currentFlightID) return null
    return this.flightByID(this.currentFlightID)
  }

  get shareToken(): string | null {
    return this.$route.params.shareToken
  }
}
