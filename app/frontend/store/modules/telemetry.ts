import Axios from 'axios'
import * as moment from 'moment'
import * as querystring from 'querystring'

import {Datapoint, TimeRange} from '../index'
import {Aircraft} from 'types'
import {ActionContext, Module} from 'vuex'
import {RootState} from '../create'
import {
  calculateInterval,
  chartDatasetsForParameter, mapToJSONObject,
  mergeTelemetry,
  unloadedRange,
  updateRanges
} from '../utilities'
import {isNil, isNumber} from "lodash-es";

export type DatapointValue = number | string | null
export type TelemetryDatapoint = Datapoint<DatapointValue>
export interface TelemetryResponse {
  interval: number
  time_range: TimeRange
  telemetry: {[keyPath: string]: Datapoint<DatapointValue>[]}
}

// interval quantized to increments of 10

export interface TelemetryState {
  telemetryByParameterAndInterval: Map<string, Map<number, TelemetryDatapoint[]>>
  loadedRangesByParameterAndInterval: Map<string, Map<number, TimeRange[]>>
  telemetryLoading: boolean
  telemetryError?: Error
}

interface FrozenTelemetryState {
  telemetryByParameterAndInterval: Array<[string, Array<[number, TelemetryDatapoint[]]>]>
  loadedRangesByParameterAndInterval: Array<[string, Array<[number, TimeRange[]]>]>
}

const state: () => TelemetryState = () => {
  return {
    // {"colname": {3: [[<millis>, <value>], ...], 30: [...]}}
    telemetryByParameterAndInterval: new Map(),
    // {"colname": {3: [[start, stop], ...], 30: [...]}}
    loadedRangesByParameterAndInterval: new Map(),

    telemetryLoading: false,
    telemetryError: null
  }
}

const getters = {
  datasetsForChart(state: TelemetryState): (parameters: string[], min: number, max: number) => TelemetryDatapoint[][] {
    return (parameters, min, max) => {
      const minInterval = calculateInterval(min, max)
      return parameters.map(parameter => {
        return chartDatasetsForParameter(
            state.telemetryByParameterAndInterval.get(parameter),
            state.loadedRangesByParameterAndInterval.get(parameter),
            minInterval)
      })
    }
  },

  telemetryLoading(state: TelemetryState): boolean { return state.telemetryLoading },
  telemetryError(state: TelemetryState): Error | null { return state.telemetryError },

  minParameterValue(state: TelemetryState): (parameters: string[]) => number | null {
    return parameters => {
      let smallest = Number.MAX_SAFE_INTEGER
      parameters.forEach(parameter => {
        if (!state.telemetryByParameterAndInterval.has(parameter)) return

        state.telemetryByParameterAndInterval.get(parameter).forEach((values, interval) => {
          values.forEach(([time, value]) => {
            if (!isNumber(value)) return
            if (value < smallest) smallest = value
          })
        })
      })

      return (smallest === Number.MAX_SAFE_INTEGER ? null : smallest)
    }
  },
  maxParameterValue(state: TelemetryState): (parameters: string[]) => number | null {
    return parameters => {
      let largest = Number.MIN_SAFE_INTEGER
      parameters.forEach(parameter => {
        if (!state.telemetryByParameterAndInterval.has(parameter)) return

        state.telemetryByParameterAndInterval.get(parameter).forEach((values, interval) => {
          values.forEach(([time, value]) => {
            if (!isNumber(value)) return
            if (value > largest) largest = value
          })
        })
      })

      return (largest === Number.MIN_SAFE_INTEGER ? null : largest)
    }
  },

  freezeTelemetry(state: TelemetryState): FrozenTelemetryState | null {
    if (state.telemetryLoading || !isNil(state.telemetryError)) return null
    return {
      telemetryByParameterAndInterval: mapToJSONObject(state.telemetryByParameterAndInterval),
      loadedRangesByParameterAndInterval: mapToJSONObject(state.loadedRangesByParameterAndInterval),
    }
  }
}

const mutations = {
  INITIALIZE_TELEMETRY(state: TelemetryState, {storedState}: {storedState: FrozenTelemetryState}) {
    let newTelemetry = new Map<string, Map<number, TelemetryDatapoint[]>>()
    storedState.telemetryByParameterAndInterval.forEach(([k, v]) => newTelemetry.set(k, new Map(v)))
    state.telemetryByParameterAndInterval = newTelemetry

    let newRanges = new Map<string, Map<number, TimeRange[]>>()
    storedState.loadedRangesByParameterAndInterval.forEach(([k, v]) => newRanges.set(k, new Map(v)))
    state.loadedRangesByParameterAndInterval = newRanges
  },

  RESET_TELEMETRY(state: TelemetryState) {
    state.telemetryByParameterAndInterval = new Map()
    state.loadedRangesByParameterAndInterval = new Map()
    state.telemetryLoading = false
    state.telemetryError = null
  },

  START_TELEMETRY(state: TelemetryState) {
    state.telemetryLoading = true
  },

  APPEND_TELEMETRY(state: TelemetryState, {interval, time_range, telemetry}: {interval: number, time_range: TimeRange, telemetry: {[parameter: string]: TelemetryDatapoint[]}}) {
    state.telemetryByParameterAndInterval =
        mergeTelemetry(state.telemetryByParameterAndInterval, telemetry, interval, time_range)
  },

  UPDATE_TELEMETRY_RANGES(state: TelemetryState, {parameters, interval, time_range}: {parameters: string[], interval: number, time_range: TimeRange}) {
    state.loadedRangesByParameterAndInterval =
        updateRanges(state.loadedRangesByParameterAndInterval, parameters, time_range, interval)
  },

  FINISH_TELEMETRY(state: TelemetryState) {
    state.telemetryLoading = false
  },

  SET_TELEMETRY_ERROR(state: TelemetryState, {error}: {error: Error}) {
    state.telemetryLoading = false
    state.telemetryError = error
  }
}

const unloadedRanges = function(state: TelemetryState, parameters: string[], interval: number, min: number, max: number): TimeRange | null {
  const allRanges: TimeRange[] = parameters.map(parameter => {
    return unloadedRange(state.loadedRangesByParameterAndInterval.get(parameter), interval, min, max)
  })

  const low: number = allRanges.reduce((min, r) => {
    if (r && r[0] < min) return r[0]
    else return min
  }, Number.MAX_SAFE_INTEGER)
  const high: number = allRanges.reduce((max, r) => {
    if (r && r[1] > max) return r[1]
    else return max
  }, Number.MIN_SAFE_INTEGER)

  if (low !== Number.MAX_SAFE_INTEGER && high !== Number.MIN_SAFE_INTEGER)
    return [low, high]
  else return null
}

const actions = {
  resetTelemetry({commit}: ActionContext<TelemetryState, RootState>) {
    commit('RESET_TELEMETRY')
  },

  loadTelemetryForChartIfNeeded({commit, state}: ActionContext<TelemetryState, RootState>, {aircraft, token, parameters, min, max}: {aircraft: Aircraft, token: string, parameters: string[], min: number, max: number}): Promise<void> {
    commit('START_TELEMETRY')

    const interval = calculateInterval(min, max)
    const rangesToLoad = unloadedRanges(state, parameters, interval, min, max)
    if (!rangesToLoad) {
      commit('FINISH_TELEMETRY')
      return Promise.resolve() // everything already loaded
    }

    const baseURL = `/aircraft/${aircraft.id}/telemetry.json?`
    const params = {
      token,
      parameters: parameters.join(','),
      start: moment(rangesToLoad[0]).format(),
      stop: moment(rangesToLoad[1]).format()
    }

    return new Promise<void>((resolve, reject) => {
      Axios.get<TelemetryResponse>(baseURL + querystring.stringify(params)).then(
          ({data: {interval, time_range, telemetry}, headers}) => {
            commit('APPEND_TELEMETRY', {interval, time_range, telemetry})
            commit('UPDATE_TELEMETRY_RANGES', {parameters, interval, time_range})
            commit('FINISH_TELEMETRY')
            resolve()
          }).catch(error => {
        commit('SET_TELEMETRY_ERROR', {error})
        reject(error)
      })
    })
  }
}

const telemetry: Module<TelemetryState, RootState> = {state, getters, mutations, actions}
export default telemetry
