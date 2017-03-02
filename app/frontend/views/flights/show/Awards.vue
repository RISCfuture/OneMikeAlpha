<template>
  <div><p>{{$t('views.flights.show.awards.title')}}</p></div>
</template>

<script lang="ts">
  import Component, {mixins} from 'vue-class-component'
  import {Prop} from 'vue-property-decorator'

  import {Aircraft, Flight} from 'types'
  import CurrentRoute from 'mixins/CurrentRoute'

  @Component
  export default class Awards extends mixins(CurrentRoute) {
    @Prop({type: Object, required: true}) aircraft: Aircraft
    @Prop({type: Object, required: true}) flight: Flight
  }
</script>
