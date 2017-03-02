/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import 'core-js/stable'
import 'regenerator-runtime/runtime'

import Vue from 'vue'

import Tabs from 'vue-tabs-component'
Vue.use(Tabs)

import VueHighcharts from 'vue-highcharts'
Vue.use(VueHighcharts)
import 'config/highcharts-extensions/scrubber'
import 'config/highcharts-extensions/noEffectOnExtremes'

import Spinner from 'components/Spinner.vue'
Vue.component('spinner', Spinner)

import store from 'store/index'
import router from 'config/router'
import i18n from 'config/i18n'

import Layout from 'views/Layout'
document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    render: create => create(Layout),
    router, store, i18n,
    beforeCreate() { this.$store.dispatch('initialize') }
  }).$mount('#app');
})

tippy.setDefaultProps({
  inertia: true,
  interactive: true,
  maxWidth: 500,
  trigger: 'manual',
  theme: 'light-border'
})

import 'config/addCSRFTokens'

import 'normalize.css'
import 'mapbox-gl/dist/mapbox-gl.css'
import 'tippy.js/dist/tippy.css'
import 'tippy.js/themes/light-border.css'

import 'stylesheets/elements.scss'
import 'stylesheets/fonts.scss'
import 'stylesheets/forms.scss'
import 'stylesheets/layout.scss'
import 'stylesheets/nav.scss'
import 'stylesheets/popover.scss'
import 'stylesheets/sourcelist.scss'
import 'stylesheets/tabs.scss'
import 'stylesheets/tooltip.scss'
import tippy from "tippy.js";
