<template>
  <tr>
    <td><strong>{{email}}</strong></td>
    <td>
      <select ref="permissionSelect"
              class="mini"
              @change="permissionLevelChanged">
        <option v-for="[id, name] in permissionLevels"
                :value="id"
                :selected="id === level">{{name}}
        </option>
      </select>
    </td>
    <td>&nbsp;</td>
  </tr>
</template>

<script lang="ts">
  import Component, {mixins} from 'vue-class-component'
  import {Prop} from 'vue-property-decorator'
  import {Getter} from 'vuex-class'
  import Axios from 'axios'

  import {Aircraft, PermissionLevel} from 'types'
  import FormHelpers from '../FormHelpers'
  import {isEmpty} from "lodash-es";

  @Component
  export default class Permission extends mixins(FormHelpers) {
    $refs!: {
      permissionSelect: HTMLSelectElement
    }

    @Prop({type: String, required: true}) aircraftId: string
    @Prop({type: String, required: true}) email: string
    @Prop({type: String, required: true}) level: PermissionLevel
    @Prop({type: Boolean, required: true}) isMe: boolean

    @Getter aircraftByID: (ID: string) => Aircraft | null

    get aircraft(): Aircraft {
      return this.aircraftByID(this.aircraftId)
    }

    private get URL(): string {
      return `/aircraft/${this.aircraft.id}/users/${this.email}/permission.json`
    }

    async permissionLevelChanged() {
      const level = this.$refs.permissionSelect.value

      if (!this.confirmIfDowngradingSelf(level)) {
        this.$refs.permissionSelect.value = this.level
        return
      }

      if (isEmpty(level)) {
        try {
          await Axios.delete(this.URL)
          this.$emit('updated')
        } catch (error) {
          alert(<string>this.$t('views.aircraft.edit.permission.failure.remove', {email: this.email}))
        }
      } else {
        try {
          await Axios.patch(this.URL, {level: level})
          this.$emit('updated')
        } catch (error) {
          alert(<string>this.$t('views.aircraft.edit.permission.failure.edit', {email: this.email}))
        }
      }
    }

    private confirmIfDowngradingSelf(newLevel: string): boolean {
      if (!this.isMe) return true
      if (this.level === PermissionLevel.Admin && newLevel !== PermissionLevel.Admin)
        return confirm(<string>this.$t('views.aircraft.edit.permission.selfRemoveWarn', {aircraft: this.aircraft.display_name}))
      else return true
    }
  }
</script>
