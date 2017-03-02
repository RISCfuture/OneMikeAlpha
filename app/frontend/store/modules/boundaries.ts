import Axios from 'axios'
import * as moment from 'moment'
import * as querystring from 'querystring'
import {ActionContext, Module} from 'vuex'

import {Aircraft} from 'types'
import {RootState} from '../create'
import {TimeRange} from '../index'
import {
  calculateInterval,
  chartDatasetsForParameter, mapToJSONObject, mergeTelemetry,
  unloadedRange, updateRanges
} from '../utilities'
import {TelemetryDatapoint} from './telemetry'
import {isNil} from "lodash-es";

interface BoundariesResponse {
  interval: number
  time_range: TimeRange
  boundaries: TelemetryDatapoint[]
}

// interval quantized to increments of 10

export interface BoundariesState {
  boundariesByParameterAndInterval: Map<string, Map<number, TelemetryDatapoint[]>>
  loadedBoundaryRangesByParameterAndInterval: Map<string, Map<number, TimeRange[]>>
  boundariesLoading: boolean
  boundariesError?: Error
}

interface FrozenBoundariesState {
  boundariesByParameterAndInterval: Array<[string, Array<[number, TelemetryDatapoint[]]>]>
  loadedBoundaryRangesByParameterAndInterval: Array<[string, Array<[number, TimeRange[]]>]>
}

const state: () => BoundariesState = () => {
  return {
    // {"colname": {3: [[<millis>, <value>], ...], 30: [...]}}
    boundariesByParameterAndInterval: new Map(),
    // {"colname": {3: [[start, stop], ...], 30: [...]}}
    loadedBoundaryRangesByParameterAndInterval: new Map(),

    boundariesLoading: false,
    boundariesError: null
  }
}

const getters = {
  boundariesForChart(state: BoundariesState): (parameter: string, min: number, max: number) => TelemetryDatapoint[] {
    return (parameter, min, max) => {
      const minInterval = calculateInterval(min, max)
      return chartDatasetsForParameter(
          state.boundariesByParameterAndInterval.get(parameter),
          state.loadedBoundaryRangesByParameterAndInterval.get(parameter),
          minInterval)
    }
  },

  boundariesLoading(state: BoundariesState): boolean { return state.boundariesLoading },
  boundariesError(state: BoundariesState): Error | null { return state.boundariesError },

  freezeBoundaries(state: BoundariesState): FrozenBoundariesState | null {
    if (state.boundariesLoading || !isNil(state.boundariesError)) return null
    return {
      boundariesByParameterAndInterval: mapToJSONObject(state.boundariesByParameterAndInterval),
      loadedBoundaryRangesByParameterAndInterval: mapToJSONObject(state.loadedBoundaryRangesByParameterAndInterval)
    }
  }
}

const mutations = {
  INITIALIZE_BOUNDARIES(state: BoundariesState, {storedState}: {storedState: FrozenBoundariesState}) {
    let newBoundaries = new Map<string, Map<number, TelemetryDatapoint[]>>()
    storedState.boundariesByParameterAndInterval.forEach(([k, v]) => newBoundaries.set(k, new Map(v)))
    state.boundariesByParameterAndInterval = newBoundaries

    let newRanges = new Map<string, Map<number, TimeRange[]>>()
    storedState.loadedBoundaryRangesByParameterAndInterval.forEach(([k, v]) => newRanges.set(k, new Map(v)))
    state.loadedBoundaryRangesByParameterAndInterval = newRanges
  },

  RESET_BOUNDARIES(state: BoundariesState) {
    state.boundariesByParameterAndInterval = new Map()
    state.loadedBoundaryRangesByParameterAndInterval = new Map()
    state.boundariesLoading = false
    state.boundariesError = null
  },

  START_BOUNDARIES(state: BoundariesState) {
    state.boundariesLoading = true
  },

  APPEND_BOUNDARIES(state: BoundariesState, {interval, time_range, parameter, boundaries}: {interval: number, time_range: TimeRange, parameter: string, boundaries: TelemetryDatapoint[]}) {
    state.boundariesByParameterAndInterval =
        mergeTelemetry(state.boundariesByParameterAndInterval, {[parameter]: boundaries}, interval, time_range)
  },

  UPDATE_BOUNDARY_RANGES(state: BoundariesState, {parameters, interval, time_range}: {parameters: string[], interval: number, time_range: TimeRange}) {
    state.loadedBoundaryRangesByParameterAndInterval =
        updateRanges(state.loadedBoundaryRangesByParameterAndInterval, parameters, time_range, interval)
  },

  FINISH_BOUNDARIES(state: BoundariesState) {
    state.boundariesLoading = false
  },

  SET_BOUNDARIES_ERROR(state: BoundariesState, {error}: {error: Error}) {
    state.boundariesLoading = false
    state.boundariesError = error
  }
}

const actions = {
  resetBoundaries({commit}: ActionContext<BoundariesState, RootState>) {
    commit('RESET_BOUNDARIES')
  },

  loadBoundariesForChartIfNeeded({commit, state}: ActionContext<BoundariesState, RootState>, {aircraft, token, parameter, min, max}: {aircraft: Aircraft, token: string, parameter: string, min: number, max: number}): Promise<void> {
    commit('START_BOUNDARIES')

    if (!aircraft) {
      commit('FINISH_BOUNDARIES')
      return Promise.resolve()
    }

    const interval = calculateInterval(min, max)
    const rangesToLoad = unloadedRange(state.loadedBoundaryRangesByParameterAndInterval.get(parameter), interval, min, max)
    if (!rangesToLoad) {
      commit('FINISH_BOUNDARIES')
      return Promise.resolve() // everything already loaded
    }

    const baseURL = `/aircraft/${aircraft.id}/telemetry/boundaries.json?`
    const params = {
      token,
      parameter: parameter,
      start: moment(rangesToLoad[0]).format(),
      stop: moment(rangesToLoad[1]).format()
    }

    return new Promise((resolve, reject) => {
      Axios.get<BoundariesResponse>(baseURL + querystring.stringify(params)).then(
          ({data: {interval, time_range, boundaries}, headers}) => {
            commit('APPEND_BOUNDARIES', {interval, time_range, parameter, boundaries})
            commit('UPDATE_BOUNDARY_RANGES', {parameter, interval, time_range})
            commit('FINISH_BOUNDARIES')
            resolve()
          }).catch(error => {
        commit('SET_BOUNDARIES_ERROR', {error})
        reject(error)
      })
    })
  }
}

const boundaries: Module<BoundariesState, RootState> = {state, getters, mutations, actions}
export default boundaries
