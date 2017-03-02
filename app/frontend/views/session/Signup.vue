<template>
  <smart-form method="POST" action="/signup.json" :object="user" object-name="user" @success="onSuccess">
    <smart-field type="email"
                 field="email"
                 autocomplete="email"
                 :placeholder="$t('views.session.form.email')"
                 ref="emailField" />
    <smart-field type="password"
                 field="password"
                 autocomplete="new-password"
                 :placeholder="$t('views.session.form.password')" />
    <smart-field type="password"
                 field="password_confirmation"
                 autocomplete="new-password"
                 :placeholder="$t('views.session.form.passwordConfirmation')" />
    <input type="submit" name="commit" :value="$t('components.sessionActions.signUp')" />
  </smart-form>
</template>

<script lang="ts">
  import Vue from 'vue'
  import Component from 'vue-class-component'
  import {Action} from 'vuex-class'
  import {AxiosResponse} from 'axios'

  import SmartForm from 'components/SmartForm/SmartForm.vue'
  import SmartField from 'components/SmartForm/SmartField.vue'

  interface User {
    email: string
    password: string
    password_confirmation: string
  }

  @Component({
    components: {SmartForm, SmartField}
  })
  export default class Signup extends Vue {
    user: User = {email: '', password: '', password_confirmation: ''}

    @Action setJWT: (params: {response: AxiosResponse}) => void

    onSuccess(response: AxiosResponse) {
      this.setJWT({response})
    }
  }
</script>
