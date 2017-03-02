import Vue from 'vue'
import VueI18n from 'vue-i18n'
Vue.use(VueI18n)

import translations_en from 'i18n/en/index'

const debug = process.env.NODE_ENV !== 'production'

const i18n = new VueI18n({
  locale: 'en',
  messages: {en: translations_en}
})

if (debug && module.hot) {
  module.hot.accept(['i18n/en/index'], () => {
    i18n.setLocaleMessage('en', require('i18n/en/index').default)
  })
}

export default i18n
