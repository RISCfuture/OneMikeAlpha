<template>
  <ul>
    <li v-if="!loggedIn">
      <a ref="loginLink" @click.prevent="loginClicked">{{$t('components.sessionActions.logIn')}}</a>
      <login ref="loginForm" />
    </li>
    <li v-if="!loggedIn">
      <a ref="signupLink" @click.prevent="signupClicked">{{$t('components.sessionActions.signUp')}}</a>
      <signup ref="signupForm" />
    </li>
    <li v-if="loggedIn"><a @click.prevent="logoutClicked">{{$t('components.sessionActions.logOut')}}</a></li>
  </ul>
</template>

<script lang="ts">
  import Vue from 'vue'
  import Component from 'vue-class-component'
  import {Action, Getter} from 'vuex-class'
  import {Watch} from 'vue-property-decorator'

  import Login from 'views/session/Login'
  import Signup from 'views/session/Signup'
  import tippy, * as Tippy from "tippy.js";

  @Component({
    components: {Login, Signup}
  })
  export default class SessionActions extends Vue {
    $refs!: {
      loginForm: Login | undefined
      signupForm: Signup | undefined
      loginLink: HTMLAnchorElement | undefined
      signupLink: HTMLAnchorElement | undefined
    }

    @Getter loggedIn: boolean
    @Action logout: () => Promise<void>

    loginPopover: Tippy.Instance
    signupPopover: Tippy.Instance

    @Watch('loggedIn')
    onLoggedInChange() {
      this.$nextTick(() => this.createPopovers())
    }

    mounted() {
      this.createPopovers()
    }

    loginClicked() {
      this.loginPopover.show()
    }

    signupClicked() {
      this.signupPopover.show()
    }

    logoutClicked() {
      this.logout()
      this.$router.push({name: 'root'})
    }

    private createPopovers() {
      const {loginForm, signupForm} = this.$refs

      if (!this.loggedIn) {
        if (!this.loginPopover)
          this.loginPopover = tippy(this.$refs.loginLink, {
            content: this.$refs.loginForm.$el,
            onShown() { loginForm.$refs.emailField.focus() }
          })

        if (!this.signupPopover)
          this.signupPopover = tippy(this.$refs.signupLink, {
            content: this.$refs.signupForm.$el,
            onShown() { signupForm.$refs.emailField.focus() }
          })
      } else {
        this.loginPopover?.destroy()
        this.loginPopover = null

        this.signupPopover?.destroy()
        this.signupPopover = null
      }
    }
  }
</script>
