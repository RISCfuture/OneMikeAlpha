<template>
  <content-container :has-content="hasCurrentFlight"
                     :loading="aircraftLoading || flightsLoading || false"
                     :error="aircraftError || flightsError"
                     :no-content-message="$t('views.flights.show.unknownFlight')">
    <flight-title :flight="currentFlight" />

    <div class="overview">
      <stats :flight="currentFlight" :share-url="shareURL" />
      <planview :aircraft="currentAircraft" :flight="currentFlight" />
    </div>

    <tabs>
      <tab :name="$t('views.flights.show.charts.title')" id="charts">
        <charts :aircraft="currentAircraft" :flight="currentFlight" />
      </tab>

      <tab :name="$t('views.flights.show.awards.title')" id="awards">
        <awards :aircraft="currentAircraft" :flight="currentFlight" />
      </tab>

      <tab :name="$t('views.flights.show.exceedances.title')" id="exceedances">
        <exceedances :aircraft="currentAircraft" :flight="currentFlight" />
      </tab>
    </tabs>
  </content-container>
</template>

<script lang="ts">
  import Component, {mixins} from 'vue-class-component'
  import {Action, Getter} from 'vuex-class'
  import {Watch} from 'vue-property-decorator'

  import {Aircraft, Flight} from 'types'
  import CurrentRoute from 'mixins/CurrentRoute'
  import ContentContainer from 'components/ContentContainer.vue'
  import FlightTitle from './show/FlightTitle.vue'
  import Awards from './show/Awards.vue'
  import Charts from './show/Charts.vue'
  import Exceedances from './show/Exceedances.vue'
  import Planview from './show/Planview.vue'
  import Stats from './show/Stats.vue'
  import {isNil} from "lodash-es";

  @Component({
    components: {ContentContainer, FlightTitle, Charts, Exceedances, Planview, Stats, Awards}
  })
  export default class Show extends mixins(CurrentRoute) {
    @Getter aircraftLoading: boolean
    @Getter aircraftError?: Error
    @Getter flightsLoading: boolean
    @Getter flightsError?: Error

    @Action resetTelemetry: () => void
    @Action loadFlight: ({aircraftID, flightID}: {aircraftID: string, flightID: string}) => Promise<Flight | null>

    get hasCurrentFlight(): boolean { return !isNil(this.currentFlight) }
    get shareURL(): string | null { return this.currentFlight ? `${window.location.origin}/flights/${this.currentFlight.share_token}` : null }

    @Watch('currentAircraft')
    onCurrentAircraftChanged(after: Aircraft, before: Aircraft) {
      if (before === after) return
      this.resetTelemetry()
    }

    @Watch('currentFlight')
    onCurrentFlightChanged(after: Flight, before: Flight) {
      if (before === after) return
      this.resetTelemetry()
      this.loadFlightIfNeeded()
    }

    mounted() { this.loadFlightIfNeeded() }

    private loadFlightIfNeeded() {
      if (this.hasCurrentFlight) return
      // this.loadFlight({aircraftID: this.currentAircraftID, flightID: this.currentFlightID})
    }
  }
</script>

<style lang="scss" scoped>
  .content-container {
    padding: 20px;
  }

  .overview {
    display: flex;
    flex-flow: row wrap;
    justify-content: flex-start;
    align-items: flex-start;

    @media only screen and (max-width: 1000px) {
      display: block;
    }

    > * {
      flex: 1 1 auto;
    }
  }
</style>
