<template>
  <form method="POST" action="/login.json">
    <input type="email"
           name="user[email]"
           autocomplete="email"
           :placeholder="$t('views.session.form.email')"
           v-model="email"
           ref="emailField" />
    <input type="password"
           name="user[password]"
           autocomplete="current-password"
           :placeholder="$t('views.session.form.password')"
           v-model="password" />
    <p v-if="error" class="error">{{error}}</p>
    <input type="submit" name="commit" :value="$t('components.sessionActions.logIn')" @click.prevent="submit" />
  </form>
</template>

<script lang="ts">
  import Vue from 'vue'
  import Component from 'vue-class-component'
  import {Action} from 'vuex-class'

  @Component
  export default class Login extends Vue {
    $refs!: {
      form: HTMLFormElement
      emailField: HTMLInputElement
    }

    email = ''
    password = ''
    error?: string = null

    @Action login: (params: {email: string, password: string}) => Promise<void>

    async submit() {
      this.error = null
      try {
        await this.login({email: this.email, password: this.password})
      } catch (e) {
        console.error(e)
        if (e.response.status === 401) this.error = <string>this.$t('views.session.login.wrongCredentials')
        else this.error = <string>this.$t('views.session.login.wrongCredentials', {error: e.response.status})
      }
    }
  }
</script>
