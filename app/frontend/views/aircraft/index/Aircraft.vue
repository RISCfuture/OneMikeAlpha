<template>
  <li v-if="isActive" class="active" ref="editLink" @click.prevent="editClicked">
    {{aircraft.display_name}}
    <edit ref="editForm" :aircraft-id="aircraft.id" @complete="editFinished" />
  </li>
  <li v-else>
    <router-link :to="{name: 'flights', params: {aircraftID: aircraftId}}">
      {{aircraft.display_name}}
    </router-link>
  </li>
</template>

<script lang="ts">
  import Vue from 'vue'
  import Component from 'vue-class-component'
  import {Prop, Watch} from 'vue-property-decorator'
  import {Action, Getter} from 'vuex-class'

  import * as Types from 'types'
  import Edit from '../Edit.vue'
  import tippy, * as Tippy from "tippy.js";

  @Component({
    components: {Edit}
  })
  export default class Aircraft extends Vue {
    $refs!: {
      editLink: HTMLLIElement | undefined
      editForm: Edit | undefined
    }

    @Prop({type: String, required: true}) aircraftId: string

    editPopover: Tippy.Instance

    @Getter loggedIn: boolean
    @Getter aircraftByID: (ID: string) => Types.Aircraft | null

    get aircraft(): Types.Aircraft {
      return this.aircraftByID(this.aircraftId)
    }

    get isActive(): boolean {
      return this.$route.params.aircraftID === this.aircraft.id
    }

    @Action loadAircraft: (params: {force: boolean}) => Promise<boolean>

    mounted() {
      this.createEditPopover()
    }

    @Watch('isActive')
    onIsActiveChanged() {
      this.$nextTick(() => this.createEditPopover())
    }

    editClicked() {
      this.editPopover.show()
    }

    editFinished() {
      this.editPopover.hide()
    }

    private createEditPopover() {
      if (this.isActive) {
        if (!this.editPopover)
          this.editPopover = tippy(this.$refs.editLink, {
            content: this.$refs.editForm.$el
          })
      } else {
        this.editPopover?.destroy()
        this.editPopover = null
      }
    }
  }
</script>

<style lang="scss" scoped>
  @import "../../../stylesheets/config.scss";

  li {
    font-weight: 600;
    padding: 3px;
    margin-right: 10px;

    &.active {
      border-radius: 3px;
      color: white;
      background-color: $red;
      font-weight: 700;

      background-image: url('../../../images/dropdown.svg');
      background-repeat: no-repeat;
      background-position: center right 5px;
      padding-right: calc(5px + 19px + 5px);
      cursor: pointer;
    }

    & a {
      display: inline-block;
    }
  }
</style>
