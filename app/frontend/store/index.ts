import Vue from 'vue'
import Vuex from 'vuex'
import Axios from 'axios'

import account from './modules/account'
import aircraft from './modules/aircraft'
import boundaries from './modules/boundaries'
import flight from './modules/flight'
import flights from './modules/flights'
import route from './modules/route'
import settings from './modules/settings'
import telemetry from './modules/telemetry'
import uploads from './modules/uploads'

import createStore from './create'

Vue.use(Vuex)

export type Datapoint<T> = [number, T]
export type TimeRange = [number, number]

const store = createStore({
  account,
  aircraft,
  boundaries,
  flight,
  flights,
  route,
  settings,
  telemetry,
  uploads
})

Axios.interceptors.request.use(config => {
  if (store.getters.loggedIn)
    config.headers['authorization'] = store.getters.authHeader
  return config
})

Axios.interceptors.response.use(response => response, error => {
  if (!error.response || !error.response.status) return Promise.reject(error)

  if (error.response.status === 401 && store.getters.loggedIn) {
    localStorage.removeItem('store')
    store.replaceState({})
    window.location.reload()
  }
  return Promise.reject(error)
})

export default store
