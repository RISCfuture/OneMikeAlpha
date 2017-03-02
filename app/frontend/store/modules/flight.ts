import {ActionContext, Module} from 'vuex'
import Axios from 'axios'

import {Aircraft, Flight} from 'types'
import {RootState} from '../create'
import {isNil, omit, pick} from "lodash-es";

export interface SharedFlightState {
  sharedAircraft?: Aircraft
  sharedFlight?: Flight
  sharedFlightLoading: boolean
  sharedFlightError?: Error
}

export type FrozenSharedFlightState = Omit<SharedFlightState, 'sharedFlightLoading' | 'sharedFlightError'>

const state: () => SharedFlightState = () => {
  return {
    sharedAircraft: null,
    sharedFlight: null,
    sharedFlightLoading: false,
    sharedFlightError: null
  }
}

type FlightWithAircraft = Flight & {aircraft: Aircraft}

const getters = {
  sharedAircraft(state: SharedFlightState): Aircraft | null { return state.sharedAircraft },
  sharedFlight(state: SharedFlightState): Flight | null { return state.sharedFlight },
  sharedFlightLoading(state: SharedFlightState): boolean { return state.sharedFlightLoading },
  sharedFlightError(state: SharedFlightState): Error | null { return state.sharedFlightError },

  freezeFlight(state: SharedFlightState): FrozenSharedFlightState | null {
    if (!isNil(state.sharedFlightError) || state.sharedFlightLoading) return null
    return pick(state, ['sharedAircraft', 'sharedFlight'])
  }
}

const mutations = {
  INITIALIZE_FLIGHT(state: SharedFlightState, {storedState}: {storedState: FrozenSharedFlightState}) {
    state.sharedAircraft = storedState.sharedAircraft
    state.sharedFlight = storedState.sharedFlight
  },

  RESET_SHARED_FLIGHT(state: SharedFlightState) {
    state.sharedAircraft = null
    state.sharedFlight = null
    state.sharedFlightLoading = false
    state.sharedFlightError = null
  },

  START_SHARED_FLIGHT(state: SharedFlightState) {
    state.sharedAircraft = null
    state.sharedFlight = null
    state.sharedFlightLoading = true
    state.sharedFlightError = null
  },

  SET_SHARED_FLIGHT(state: SharedFlightState, {flight}: {flight: FlightWithAircraft}) {
    state.sharedAircraft = flight.aircraft
    state.sharedFlight = omit(flight, ['aircraft'])
    state.sharedFlightLoading = false
  },

  SET_SHARED_FLIGHT_ERROR(state: SharedFlightState, {error}: {error: Error}) {
    state.sharedFlightError = error
    state.sharedFlightLoading = false
  }
}

const actions = {
  clearSharedFlight({commit}: ActionContext<SharedFlightState, RootState>) {
    commit('RESET_SHARED_FLIGHT')
  },

  loadSharedFlight({commit, state}: ActionContext<SharedFlightState, RootState>, {shareToken}: {shareToken: string}): Promise<void> {
    return new Promise((resolve, reject) => {
      commit('START_SHARED_FLIGHT')

      Axios.get<FlightWithAircraft>(`/flights/${shareToken}.json`)
          .then(({data: flight}) => {
            commit('SET_SHARED_FLIGHT', {flight})
            resolve()
          })
          .catch(error => {
            commit('SET_SHARED_FLIGHT_ERROR', {error})
            reject(error)
          })
    })
  },
}

const flight: Module<SharedFlightState, RootState> = {state, getters, mutations, actions}
export default flight
