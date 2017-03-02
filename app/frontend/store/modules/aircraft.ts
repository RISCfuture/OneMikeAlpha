import Axios from 'axios'
import {ActionContext, Module} from 'vuex'

import {Aircraft} from 'types'
import {RootState} from '../create'
import {forOwn, pick} from "lodash-es";

export interface AircraftState {
  aircraft: Aircraft[]
  aircraftLoaded: boolean
  aircraftLoading: boolean
  aircraftError?: Error
}

type FrozenAircraftState = Omit<AircraftState, 'aircraftLoading' | 'aircraftError'>

const state: AircraftState = {
  aircraft: [],
  aircraftLoaded: false,
  aircraftLoading: false,
  aircraftError: null
}

const getters = {
  aircraft(state: AircraftState): Aircraft[] { return state.aircraftLoaded ? state.aircraft : [] },
  aircraftCount(state: AircraftState): number { return state.aircraft.length },
  aircraftError(state: AircraftState): Error | null { return state.aircraftError },
  aircraftLoading(state: AircraftState): boolean { return state.aircraftLoading },

  aircraftByID(state: AircraftState): (ID: string) => Aircraft | null {
    return ID => state.aircraft.find(a => a.id === ID)
  },

  freezeAircraft(state: AircraftState): FrozenAircraftState | null {
    if (state.aircraftLoading || state.aircraftError) return null
    return pick(state, ['aircraft', 'aircraftLoaded'])
  }
}

const mutations = {
  INITIALIZE_AIRCRAFT(state: AircraftState, {storedState}: {storedState: FrozenAircraftState}) {
    forOwn(storedState, (v, k) => state[k] = v)
  },

  RESET_AIRCRAFT(state: AircraftState) {
    state.aircraft = []
    state.aircraftLoaded = false
    state.aircraftError = null
  },

  APPEND_AIRCRAFT(state: AircraftState, {aircraft}: {aircraft: Aircraft}) {
    state.aircraft = state.aircraft.concat(aircraft)
  },

  FINISH_AIRCRAFT(state: AircraftState) {
    state.aircraftLoaded = true
    state.aircraftLoading = false
  },

  SET_AIRCRAFT_ERROR(state: AircraftState, {error}: {error: Error}) {
    state.aircraft = []
    state.aircraftLoaded = true
    state.aircraftLoading = false
    state.aircraftError = error
  },

  START_AIRCRAFT(state: AircraftState) {
    state.aircraftLoading = true
  }
}

const actions = {
  resetAircraft({commit}: ActionContext<AircraftState, RootState>) {
    commit('RESET_AIRCRAFT')
  },

  loadAircraft({commit, state}: ActionContext<AircraftState, RootState>, {force}: {force: boolean} = {force: false}): Promise<boolean> {
    if (!force && state.aircraftLoaded) return Promise.resolve(false)
    if (state.aircraftLoading) return Promise.resolve(false)

    return new Promise<boolean>((resolve, reject) => {
      commit('START_AIRCRAFT')
      Axios.get('/aircraft.json').then(({data: aircraft, headers}) => {
        commit('RESET_AIRCRAFT')
        commit('APPEND_AIRCRAFT', {aircraft})

        const pages = Number.parseInt(headers['x-pages'])
        let promises = []
        for (let page = 2; page <= pages; page++) {
          promises.push(Axios.get(`/aircraft.json?page=${page}`)
                             .then(({data: aircraft}) => commit('APPEND_AIRCRAFT', {aircraft})))
        }
        Promise.all(promises)
               .then(() => { commit('FINISH_AIRCRAFT'); resolve(true); })
               .catch(error => { commit('SET_AIRCRAFT_ERROR', {error}); reject(error); })
      }).catch(error => { commit('SET_AIRCRAFT_ERROR', {error}); reject(error); })
    })
  },

  deleteAircraft({dispatch}: ActionContext<AircraftState, RootState>, {id}: { id: number }): Promise<void> {
    return new Promise((resolve, reject) => {
      Axios.delete(`/aircraft/${id}.json`)
          .then(() => {
            dispatch('loadAircraft', {force: true})
                .then(() => resolve())
                .catch(error => reject(error))
          })
          .catch(error => reject(error))
    })
  }
}

const aircraft: Module<AircraftState, RootState> = {state, getters, mutations, actions}
export default aircraft
