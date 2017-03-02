<template>
  <div>
    <dl>
      <template v-if="showDepartureArrivalTimes">
        <dt>{{$t('views.flights.show.stats.departureArrival')}}</dt>
        <dd>
          {{$t('views.flights.show.stats.rangeValue', {
                from: time(flight.departure_time, flight.origin),
                to: time(flight.arrival_time, flight.destination)})}}
            <a v-if="showTimezoneToggle" class="muted" @click.prevent="toggleUseLocalTimezones">{{timezoneLinkTitle}}</a>
        </dd>
      </template>

      <template v-if="showTakeoffLandingTimes">
        <dt>{{$t('views.flights.show.stats.takeoffLanding')}}</dt>
        <dd>
          {{$t('views.flights.show.stats.rangeValue', {
                from: time(flight.takeoff_time, flight.origin),
                to: time(flight.landing_time, flight.destination)})}}
        </dd>
      </template>

      <template v-if="showDuration">
        <dt>{{$t('views.flights.show.stats.duration')}}</dt>
        <dd>{{flight.duration | durationConverter | numberFormatter}} hr</dd>
      </template>

      <template v-if="showDistance">
        <dt>{{$t('views.flights.show.stats.directDistance')}}</dt>
        <dd>{{flight.distance | distanceConverter | numberFormatter}} NM</dd>
      </template>

      <dt>{{$t('views.flights.show.stats.distanceFlown')}}</dt>
      <dd>{{flight.distance_flown | distanceConverter | numberFormatter}} NM</dd>
    </dl>

    <p v-if="shareUrl">
      <a :href="shareUrl" @click.prevent="shareFlight"><img id="share-icon" :src="shareImageURL" />&nbsp;{{$t('views.flights.show.stats.shareLink')}}</a>
    </p>
  </div>
</template>

<script lang="ts">
  import Vue from 'vue'
  import Component from 'vue-class-component'
  import {Action, Getter} from 'vuex-class'
  import {Prop} from 'vue-property-decorator'
  import * as moment from 'moment-timezone'
  import * as numeral from 'numeral'
  import * as Qty from 'js-quantities'

  import {Airport, Flight} from 'types'
  import i18n from 'config/i18n'

  import ShareImageURL from 'images/share.svg'
  import {get, has} from "lodash-es";

  @Component({
    filters: {
      numberFormatter(value: number): string { return numeral(value).format(<string>i18n.t('number.flightHours')) },
      distanceConverter(value: number): number { return Qty(value, 'm').to('nmi').scalar },
      durationConverter(value: number): number { return Qty(value, 's').to('hr').scalar }
    }
  })
  export default class Stats extends Vue {
    @Prop({type: Object, required: true}) flight: Flight
    @Prop({type: String}) shareUrl: string

    @Getter useLocalTimezones: boolean

    get showDistance(): boolean {
      return get(this.flight, 'origin.identifier') !== get(this.flight, 'destination.identifier')
    }
    get showDuration(): boolean { return typeof this.flight.duration === 'number' }
    get showDepartureArrivalTimes(): boolean { return typeof this.flight.departure_time === 'string' && typeof this.flight.arrival_time === 'string' }
    get showTakeoffLandingTimes(): boolean { return typeof this.flight.takeoff_time === 'string' && typeof this.flight.landing_time === 'string' }

    get showTimezoneToggle(): boolean {
      return has(this.flight, 'origin.timezone') && has(this.flight, 'destination.timezone')
    }

    get timezoneLinkTitle(): string {
      return this.useLocalTimezones ?
          <string>this.$t('views.flights.show.stats.toggleTimezoneLink.utc') :
          <string>this.$t('views.flights.show.stats.toggleTimezoneLink.local')
    }

    get shareImageURL(): string { return ShareImageURL }

    @Action toggleUseLocalTimezones: () => void

    time(timeInt: number, place: Airport): string {
      const time = moment(timeInt)
      if (this.showTimezoneToggle && this.useLocalTimezones)
        return time.tz(place.timezone).format(<string>this.$t('date.fullLocal'));
      else return <string>this.$t('date.fullZuluFormat', {date: time.utc().format(<string>this.$t('date.fullZulu'))})
    }

    shareFlight() {
      prompt(<string>this.$t('views.flights.show.stats.sharePrompt'), this.shareUrl)
    }
  }
</script>

<style lang="scss" scoped>
  @import "../../../stylesheets/config.scss";

  div {
    flex: 0 1 50%;
    padding-right: 20px;
    box-sizing: border-box;
  }

  dt {
    font-weight: 700;
    font-size: 11px;
    text-transform: uppercase;
    color: $tuscany;
  }

  dd {
    margin-left: 0;
    font-size: 14px;
    color: black;
  }

  dd:not(:last-child) {
    margin-bottom: 10px;
  }

  img#share-icon {
    height: 16px;
  }
</style>
