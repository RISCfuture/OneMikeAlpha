import {ActionContext, Module} from 'vuex'
import {RootState} from '../create'

export interface SettingsState {
  useLocalTimezones: boolean
}

const state: SettingsState = {
  useLocalTimezones: false
}

const getters = {
  useLocalTimezones(state: SettingsState): boolean { return state.useLocalTimezones }
}

const mutations = {
  TOGGLE_USE_LOCAL_TIMEZONES(state: SettingsState) {
    state.useLocalTimezones = !state.useLocalTimezones
  }
};

const actions = {
  toggleUseLocalTimezones({commit}: ActionContext<SettingsState, RootState>) {
    commit('TOGGLE_USE_LOCAL_TIMEZONES')
  }
}

const settings: Module<SettingsState, RootState> = {state, getters, mutations, actions}
export default settings
