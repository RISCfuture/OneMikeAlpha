<template>
  <article class="full-bleed">
    <p v-if="!loggedIn" class="big-help">{{$t('views.aircraft.none.logIn')}}</p>
    <p v-else-if="anyAircraft" class="big-help">{{$t('views.aircraft.none.choose')}}</p>
    <div v-else id="no-aircraft">
      <div class="help">
        <h1>{{$t('views.aircraft.none.clickPlus')}}</h1>
        <p>{{$t('views.aircraft.none.requestPermission')}}</p>
      </div>
    </div>
  </article>
</template>

<script lang="ts">
  import Vue from 'vue'
  import Component from 'vue-class-component'
  import {Getter} from 'vuex-class'

  @Component
  export default class None extends Vue {
    @Getter aircraftCount: number
    @Getter loggedIn: boolean

    get anyAircraft(): boolean {
      return this.aircraftCount > 0
    }
  }
</script>

<style lang="scss" scoped>
  #no-aircraft p {
    text-align: center;
  }
</style>
