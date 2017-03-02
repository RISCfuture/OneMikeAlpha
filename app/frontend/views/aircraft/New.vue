<template>
  <smart-form method="post" action="/aircraft.json" :object="newAircraft" object-name="aircraft" @success="onSuccess">
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

    <input type="submit" name="commit" :value="$t('views.aircraft.new.addButton')" />

    <p class="muted">
      {{$t('views.aircraft.new.notSupportedYet')}}<br />
      <a href="#">{{$t('views.aircraft.new.helpUs')}}</a>
    </p>
  </smart-form>
</template>

<script lang="ts">
  import Component, {mixins} from 'vue-class-component'

  import SmartField from 'components/SmartForm/SmartField.vue'
  import SmartForm from 'components/SmartForm/SmartForm.vue'
  import FormHelpers from './FormHelpers'

  interface NewAircraft {
    registration: string
    name?: string
    aircraft_data: string
    equipment_data: string
  }

  @Component({
    components: {SmartForm, SmartField}
  })
  export default class New extends mixins(FormHelpers) {
    newAircraft: NewAircraft = {
      registration: '',
      aircraft_data: '',
      equipment_data: ''
    }

    onSuccess() { this.$emit('success') }
  }
</script>
