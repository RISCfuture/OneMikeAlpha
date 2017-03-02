<template>
  <div>
    <smart-form :action="URL"
                :object="aircraft"
                @success="onSuccess"
                @complete="onComplete"
                method="patch"
                object-name="aircraft">
      <fieldset>
        <label for="aircraft[registration]">{{$t('views.aircraft.form.registration')}}</label>
        <smart-field type="text" field="registration" required maxlength="10" placeholder="N123AB" />

        <label for="aircraft[name]">{{$t('views.aircraft.form.name')}}</label>
        <smart-field type="text" field="name" maxlength="20" :placeholder="$t('general.forms.optionalPlaceholder')" />
      </fieldset>

      <fieldset>
        <label for="aircraft[aircraft_data]">{{$t('views.aircraft.form.type')}}</label>
        <smart-field type="select" field="aircraft_data" required>
          <option />
          <optgroup v-for="manufacturer in aircraftTypes" :label="manufacturer.name">
            <option v-for="type in manufacturer.types" :value="type.id">{{type.name}}</option>
          </optgroup>
        </smart-field>

        <label for="aircraft[equipment_data]">{{$t('views.aircraft.form.equipment')}}</label>
        <smart-field type="select" field="equipment_data" required>
          <option />
          <optgroup v-for="manufacturer in equipmentTypes" :label="manufacturer.name">
            <option v-for="type in manufacturer.types" :value="type.id">{{type.name}}</option>
          </optgroup>
        </smart-field>
      </fieldset>

      <div class="form-actions">
        <input type="submit" name="commit" :value="$t('general.forms.update')" />
        <button v-if="showDelete" class="danger" @click.prevent="confirmDelete">{{$t('general.forms.delete')}}</button>
      </div>
    </smart-form>

    <fieldset v-if="showPermissions" class="permissions-label">
      <label>{{$t('views.aircraft.form.permissionsHeader')}}</label>
      <table>
        <permission v-for="(level, email) in aircraft.permissions"
                    :key="email"
                    :aircraft-id="aircraftId"
                    :email="email"
                    :level="level"
                    :is-me="currentUserEmail === email"
                    @updated="onSuccess" />
        <add-permission :aircraft-id="aircraftId" @added="onSuccess" />
      </table>
    </fieldset>
  </div>
</template>

<script lang="ts">
  import Component, {mixins} from 'vue-class-component'
  import {Prop} from 'vue-property-decorator'
  import {Action, Getter} from 'vuex-class'

  import {Aircraft, PermissionLevel} from 'types'
  import SmartForm from 'components/SmartForm/SmartForm.vue'
  import SmartField from 'components/SmartForm/SmartField.vue'
  import FormHelpers from './FormHelpers'
  import Permission from './edit/Permission.vue'
  import AddPermission from './edit/AddPermission.vue'
  import {isNil} from "lodash-es";

  @Component({
    components: {AddPermission, Permission, SmartField, SmartForm}
  })
  export default class Edit extends mixins(FormHelpers) {
    @Prop({type: String, required: true}) aircraftId: string

    @Getter loggedIn: boolean
    @Getter currentUserEmail?: string
    @Getter aircraftByID: (ID: string) => Aircraft | null

    get aircraft(): Aircraft {
      return this.aircraftByID(this.aircraftId)
    }

    get showDelete(): boolean {
      return this.aircraft.permission.level === PermissionLevel.Admin
    }

    get showPermissions(): boolean {
      return this.aircraft.permission.level === PermissionLevel.Admin &&
          !isNil(this.aircraft.permissions)
    }

    get URL(): string { return `/aircraft/${this.aircraftId}.json` }

    @Action deleteAircraft: (params: {id: string}) => Promise<void>
    @Action loadAircraft: (options: {force: boolean}) => Promise<boolean>

    async confirmDelete() {
      if (!confirm(<string>this.$t('views.aircraft.edit.confirmDelete', {aircraft: this.aircraft.display_name}))) return

      try {
        await this.deleteAircraft({id: this.aircraftId})
        this.$router.push({name: 'root'})
      } catch (error) {
        alert(<string>this.$t('views.aircraft.edit.deleteFailed', {aircraft: this.aircraft.display_name}))
      }
    }

    async onSuccess() {
      await this.loadAircraft({force: true})
      this.$emit('success')
    }

    onComplete() { this.$emit('complete') }
  }
</script>

<style lang="scss" scoped>
  table {
    width: 100%;
  }

  .permissions-label {
    margin-top: 20px;
  }
</style>
