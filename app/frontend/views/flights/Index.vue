<template>
  <content-container :has-content="hasCurrentAircraft"
                     :loading="aircraftLoading"
                     :error="aircraftError"
                     :no-content-message="$t('views.flights.index.unknownAircraft')"
                     class="full-bleed">
    <list />

    <article>
      <router-view />
    </article>
  </content-container>
</template>

<script lang="ts">
  import Component, {mixins} from 'vue-class-component'
  import {Getter} from 'vuex-class'

  import ContentContainer from 'components/ContentContainer.vue'
  import List from './index/List.vue'
  import CurrentRoute from 'mixins/CurrentRoute'
  import {isNil} from "lodash-es";

  @Component({
    components: {ContentContainer, List}
  })
  export default class Index extends mixins(CurrentRoute) {
    @Getter aircraftLoading: boolean
    @Getter aircraftError?: Error
    @Getter loggedIn: boolean

    get hasCurrentAircraft(): boolean { return !isNil(this.currentAircraft) }
  }
</script>

<style lang="scss" scoped>
  @import "../../stylesheets/config.scss";

  div.full-bleed {
    display: grid;
    grid-template-rows: 1fr;
    grid-template-columns: 125px 1fr;
    grid-template-areas: "sourcelist content";
  }
</style>
