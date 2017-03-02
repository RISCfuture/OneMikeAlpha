<template>
  <content-container :has-content="hasSharedFlight"
                     :loading="sharedFlightLoading"
                     :error="sharedFlightError"
                     :no-content-message="$t('views.flights.shared.badURL')">
    <flight-title :flight="sharedFlight" />

    <div class="overview">
      <stats :flight="sharedFlight" />
      <planview :aircraft="sharedAircraft" :flight="sharedFlight" />
    </div>

    <tabs>
      <tab :name="$t('views.flights.show.charts.title')" id="charts">
        <charts :aircraft="sharedAircraft" :flight="sharedFlight" />
      </tab>

      <tab :name="$t('views.flights.show.awards.title')" id="awards">
        <awards :aircraft="sharedAircraft" :flight="sharedFlight" />
      </tab>

      <tab :name="$t('views.flights.show.exceedances.title')" id="exceedances">
        <exceedances :aircraft="sharedAircraft" :flight="sharedFlight" />
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
  import ContentContainer from 'components/ContentContainer'
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
  export default class Shared extends mixins(CurrentRoute) {
    @Getter sharedFlightLoading: boolean
    @Getter sharedFlightError?: Error
    @Getter sharedAircraft?: Aircraft
    @Getter sharedFlight?: Flight

    @Action loadSharedFlight: (params: {shareToken: string}) => Promise<void>

    get hasSharedFlight(): boolean {
      return !isNil(this.sharedAircraft) && !isNil(this.sharedFlight)
    }

    @Watch('shareToken')
    onShareTokenChanged(shareToken: string) {
      this.loadSharedFlight({shareToken})
    }

    created() {
      this.loadSharedFlight({shareToken: this.shareToken})
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
