<template>
    <tr>
      <td>
        <input type="email"
               placeholder="email"
               class="mini"
               v-model="email" />
      </td>
      <td>
        <select class="mini" name="permission[level]" v-model="level">
          <option v-for="[id, name] in newPermissionLevels" :value="id">{{name}}
          </option>
        </select>
      </td>
      <td>
        <input type="submit"
               name="commit"
               :value="$t('views.aircraft.edit.addPermission.add')"
               class="mini"
               @click.prevent="onSubmit" />
      </td>
    </tr>
</template>

<script lang="ts">
  import Component, {mixins} from 'vue-class-component'
  import {Prop} from 'vue-property-decorator'
  import {Getter} from 'vuex-class'
  import Axios from 'axios'

  import {Aircraft} from 'types'
  import FormHelpers from '../FormHelpers'

  @Component
  export default class AddPermission extends mixins(FormHelpers) {
    $refs!: {
      form: HTMLFormElement
    }

    email = ''
    level = 'view'

    @Prop({type: String, required: true}) aircraftId: string

    @Getter aircraftByID: (ID: string) => Aircraft | null

    get aircraft(): Aircraft {
      return this.aircraftByID(this.aircraftId)
    }

    private get URL(): string {
      return `/aircraft/${this.aircraft.id}/users/${this.email}/permission.json`
    }

    async onSubmit() {
      try {
        await Axios.patch(this.URL, {permission: {level: this.level}})
        this.$emit('added')
      } catch (error) {
        if (error.response.status === 404)
          alert(this.$t('views.aircraft.edit.addPermission.failure.noUser', {email: this.email}))
        else
          alert(this.$t('views.aircraft.edit.addPermission.failure.other', {email: this.email, aircraft: this.aircraft.display_name}))
      }
    }
  }
</script>
