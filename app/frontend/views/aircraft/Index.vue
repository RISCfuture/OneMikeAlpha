<template>
  <div class="body-container">
    <add-aircraft ref="addForm" @success="aircraftCreated" />
    <nav>
      <ul v-if="loggedIn">
        <aircraft v-for="a in aircraft" :key="a.id" :aircraft-id="a.id" />
        <li id="add-aircraft">
          <a ref="addLink" @click.prevent="addClicked">+<span id="plus-explanation" :class="{'force-visible': popoverVisible}">&nbsp;{{$t('views.aircraft.index.addLink')}}</span></a>
        </li>
      </ul>
      <div class="spacer">&nbsp;</div>
      <session-actions></session-actions>
    </nav>

    <router-view />
  </div>
</template>

<script lang="ts">
  import Component, {mixins} from 'vue-class-component'
  import {Action, Getter} from 'vuex-class'
  import {Watch} from 'vue-property-decorator'

  import Aircraft from './index/Aircraft.vue'
  import SessionActions from 'components/SessionActions.vue'
  import CurrentRoute from 'mixins/CurrentRoute'
  import New from './New.vue'
  import tippy, * as Tippy from "tippy.js";

  @Component({
    components: {Aircraft, SessionActions, addAircraft: New}
  })
  export default class Index extends mixins(CurrentRoute) {
    addPopover: Tippy.Instance
    popoverVisible = false

    @Getter aircraft: Aircraft
    @Getter loggedIn: boolean

    @Action resetAircraft: () => void
    @Action loadAircraft: (params: { force: boolean }) => Promise<boolean>

    created() {
      if (this.loggedIn) this.loadAircraft({force: true})
    }

    mounted() {
      this.createAddPopover()
    }

    @Watch('loggedIn')
    onLoggedInChanged(cur: boolean) {
      if (cur) this.loadAircraft({force: true})
      else this.resetAircraft()
      this.$nextTick(() => this.createAddPopover())
    }

    aircraftCreated() {
      this.addPopover.hide()
      if (this.loggedIn) this.loadAircraft({force: true})
    }

    addClicked() {
      this.addPopover.show()
    }

    private createAddPopover() {
      if (this.loggedIn) {
        if (!this.addPopover)
          this.addPopover = tippy(this.$refs.addLink, {
            content: this.$refs.addForm.$el,
            onShown: () => this.popoverVisible = true,
            onHidden: () => this.popoverVisible = false,
          })
      } else {
        this.addPopover?.destroy()
        this.addPopover = null
      }
    }
  }
</script>

<style lang="scss" scoped>
  @import "../../stylesheets/config.scss";

  #add-aircraft a {
    border-radius: 3px;
    background-color: $dark-gray;
    padding: 0 10px;
    display: inline-block;
    color: white;

    &:hover {
      background-color: $gray;

      & #plus-explanation {
        max-width: 200px;
      }
    }
  }

  #plus-explanation {
    color: white;
    font-weight: 200;
    max-width: 0;
    overflow-x: hidden;
    white-space: nowrap;
    transition: max-width 0.5s;
    display: inline-block;
    vertical-align: middle;

    &.force-visible {
      max-width: 200px;
    }
  }
</style>
