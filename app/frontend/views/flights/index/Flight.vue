<template>
  <li :class="{'active': isActive}">
    <router-link :to="{name: 'flight', params: {flightID: flight.id}, query: {charts: $route.query.charts, marker: $route.query.marker}}">
      <span v-if="flight.origin">{{flight.origin.identifier}}</span>
      <span v-else class="muted">{{$t('general.airport.unknownLID')}}</span>
      {{$t('general.flight.arrow')}}
      <span v-if="flight.destination">{{flight.destination.identifier}}</span>
      <span v-else class="muted">{{$t('general.airport.unknownLID')}}</span>
    </router-link>
  </li>
</template>

<script lang="ts">
  import Vue from 'vue'
  import scrollIntoView from 'scroll-into-view'
  import inViewport from 'in-viewport'
  import Component from 'vue-class-component'
  import {Prop, Watch} from 'vue-property-decorator'

  import * as Types from 'types'

  @Component
  export default class Flight extends Vue {
    @Prop({type: Object, required: true}) flight: Types.Flight

    get isActive(): boolean {
      return this.$route.params.flightID == this.flight.id.toString()
    }

    private scrollIntoViewIfActive() {
      if (!this.isActive) return
      if (inViewport(this.$el)) return
      scrollIntoView(this.$el, {time: 100})
    }

    @Watch('isActive')
    onIsActiveChanged(after: boolean, before: boolean) {
      if (before === after) return
      this.scrollIntoViewIfActive()
    }

    mounted() { this.scrollIntoViewIfActive() }
  }
</script>
