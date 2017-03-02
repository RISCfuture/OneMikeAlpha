<template>
  <aside class="sourcelist">
    <div id="sticky-header">
      <a ref="importLink" id="import-telemetry" @click.prevent="importClicked">{{importLinkTitle}}</a>
      <import ref="importContent" />
      <input type="search" v-model="filter" :placeholder="$t('views.flights.index.list.filterPlaceholder')" />
    </div>

    <spinner v-if="flightsLoading && firstLoad" />
    <ul v-else>
      <template v-for="group in flightsByDate">
        <li class="header">{{group.date | dateFormatter}}</li>
        <flight v-for="flight in group.flights"
                :key="flight.id"
                :flight="flight" />
      </template>
    </ul>
  </aside>
</template>

<script lang="ts">
  import * as moment from 'moment'
  import * as numeral from 'numeral'
  import Component, {mixins} from 'vue-class-component'
  import {Action, Getter} from 'vuex-class'
  import {Watch} from 'vue-property-decorator'

  import {Aircraft, Upload} from 'types'
  import CurrentRoute from 'mixins/CurrentRoute'
  import InfiniteScroll from 'mixins/InfiniteScroll'
  import Flight from './Flight'
  import {FlightGroup} from 'store/modules/flights'
  import Import from '../Import'
  import i18n from 'config/i18n'
  import tippy, * as Tippy from "tippy.js";

  @Component({
    components: {Flight, Import},
    filters: {
      dateFormatter(date: Date): string { return moment(date).format(<string>i18n.t('date.dateOnlyMedium')) }
    }
  })
  export default class List extends mixins(CurrentRoute, InfiniteScroll) {
    $refs!: {
      header: HTMLElement
      footer: HTMLElement
      importLink: HTMLAnchorElement
      importContent: Import
    }

    filter?: string = null
    filterTimeout?: number = null
    firstLoad = true
    maxSortKey: number
    minSortKey: number

    importPopover: Tippy.Instance

    @Getter flightsLoading: boolean
    @Getter flightsByDate: FlightGroup[]
    @Getter incompleteUploads: Upload[]

    get importLinkTitle(): string {
      return this.$tc('views.flights.index.list.importLink',
          this.incompleteUploads.length,
          {count: numeral(this.incompleteUploads.length).format(<string>this.$t('number.integer'))})
    }

    @Action clearFlights: () => void
    @Action loadFlightsWithIDLowerThan: (params: {aircraftID: string, force?: boolean, filter?: string, ID?: number}) => Promise<number | null>
    @Action loadFlightsWithIDHigherThan: (params: {aircraftID: string, force?: boolean, filter?: string, ID?: number}) => Promise<number | null>

    prevPage() {
      // record our current scroll position so we can add the new page of
      // flights above our current scroll position without changing the scroll
      // position
      const oldScrollTop = this.$el.scrollTop
      const oldScrollHeight = this.$el.scrollHeight

      this.loadFlightsWithIDHigherThan({aircraftID: this.currentAircraftID, filter: this.filter, ID: this.maxSortKey})
          .then(maxSortKey => this.maxSortKey = maxSortKey)
          .then(() => {
            // adjust the scroll position to account for the increased scroll
            // height
            const heightDifference = this.$el.scrollHeight - oldScrollHeight
            this.$el.scrollTop = oldScrollTop + heightDifference
          })
    }

    nextPage() {
      this.loadFlightsWithIDLowerThan({aircraftID: this.currentAircraftID, filter: this.filter, ID: this.minSortKey})
          .then(minSortKey => { if (minSortKey) this.minSortKey = minSortKey })
    }

    private get currentFlightTime(): number | null {
      if (!this.currentFlightID) return null
      const datePart = this.currentFlightID.split('_')[0]
      const date = moment(datePart, 'YYYY-MM-DD')
      if (!date) return null
      return date.unix()
    }

    private get currentTimeFraction(): number { return moment().unix() + moment().milliseconds()/1000 }

    private reloadFlights({delay}: {delay: boolean}): Promise<boolean> {
      return new Promise((resolve, reject) => {
        this.maxSortKey = this.currentFlightTime || this.currentTimeFraction
        this.minSortKey = this.currentFlightTime || this.currentTimeFraction

        if (!this.currentAircraft) return resolve(false)

        if (this.filterTimeout) window.clearTimeout(this.filterTimeout)
        if (delay) {
          this.filterTimeout =
              window.setTimeout(() => this.reloadFlights({delay: false}), 500)
          return resolve(false)
        }

        this.clearFlights()
        const loadHigher = this.loadFlightsWithIDHigherThan({
          aircraftID: this.currentAircraftID,
          filter: this.filter,
          ID: this.maxSortKey,
          force: true
        }).then(maxSortKey => { if (maxSortKey) this.maxSortKey = maxSortKey })
        const loadLower = this.loadFlightsWithIDLowerThan({
          aircraftID: this.currentAircraftID,
          filter: this.filter,
          ID: this.minSortKey,
          force: true
        }).then(minSortKey => { if (minSortKey) this.minSortKey = minSortKey })

        Promise.all([loadHigher, loadLower]).then(() => resolve(true)).catch(err => reject(err))
      })
    }

    importClicked() {
      this.importPopover.show()
    }

    async created() {
      if (!this.currentAircraftID) return

      const actuallyReloaded = await this.reloadFlights({delay: false})
      if (actuallyReloaded) this.firstLoad = false
    }

    mounted() {
      this.inhibitScroll = () => this.flightsLoading
      this.$on('top', () => this.prevPage())
      this.$on('bottom', () => this.nextPage())

      this.importPopover = tippy(this.$refs.importLink, {
        content: this.$refs.importContent.$el,
        appendTo: document.body,
        placement: 'bottom'
      })
    }

    @Watch('filter')
    onFilterChanged(after: string, before: string) {
      if (before === after) return
      this.firstLoad = true
      this.reloadFlights({delay: true}).then(actuallyReloaded => {
          if (actuallyReloaded) this.firstLoad = false
        })
    }

    @Watch('currentAircraft')
    onCurrentAircraftChanged(after: Aircraft, before: Aircraft) {
      if (!after) return
      if (before && before.id === after.id) return

      this.reloadFlights({delay: false}).then(actuallyReloaded => {
          if (actuallyReloaded) this.firstLoad = false
        })
    }
  }
</script>

<style lang="scss" scoped>
  @import "../../../stylesheets/config.scss";

  aside {
    box-sizing: border-box;
    padding-top: 0; /* move padding to the sticky header so scrolled content doesn't show behind it */

    #sticky-header {
      position: sticky;
      top: 0;
      background-color: $platinum;
      border-bottom: 1px solid $medium-gray;
      padding: 10px;
    }

    ul {
      margin-top: 10px;
    }
  }

  #import-telemetry {
    display: block;
    margin-bottom: 10px;
    font-size: 80%;
  }

  input[type=search] {
    display: block;
    width: calc(100% - 20px);
    border: none;
  }


</style>

<style lang="scss">
  aside .uil-default-css {
    padding-top: 0;
    margin-top: 0;
    top: calc(50% - 100px / 2);
    transform: scale(0.25);
    width: 100px;
    height: 100px;
  }
</style>
