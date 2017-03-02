<template>
  <div class="header">
    <div v-if="flight.origin">
      <h1>{{flight.origin.identifier}}</h1>
      <p>{{flight.origin.name}}</p>
    </div>
    <div v-else>
      <h1 class="muted">{{$t('general.airport.unknownLID')}}</h1>
    </div>
    <div class="arrow">{{$t('general.flight.arrow')}}</div>
    <div v-if="flight.destination">
      <h1>{{flight.destination.identifier}}</h1>
      <p>{{flight.destination.name}}</p>
    </div>
    <div v-else>
      <h1 class="muted">{{$t('general.airport.unknownLID')}}</h1>
    </div>
  </div>
</template>

<script lang="ts">
  import Component, {mixins} from 'vue-class-component'
  import {Prop} from 'vue-property-decorator'

  import {Flight} from 'types'
  import CurrentRoute from 'mixins/CurrentRoute'

  @Component
  export default class FlightTitle extends mixins(CurrentRoute) {
    @Prop({type: Object, required: true}) flight: Flight
  }
</script>

<style lang="scss" scoped>
  @import "../../../stylesheets/config.scss";

  .header {
    display: flex;
    flex-flow: row nowrap;
    justify-content: center;
    align-content: center;
    align-items: center;
    margin-bottom: 20px;
    color: $red;

    > :not(.arrow) {
      flex: 1 1 50%;
    }

    > .arrow {
      flex: 0 0 auto;
      padding: 0 10px;
      font-size: 44px;
      line-height: 44px;
      margin: 0;
    }

    > :first-child {
      text-align: right;
    }

    > :last-child {
      text-align: left;
    }

    h1 {
      font-size: 44px;
      line-height: 44px;
      font-weight: 200;
      margin: 0;
    }

    p {
      font-size: 11px;
      margin: 0;
    }
  }
</style>
