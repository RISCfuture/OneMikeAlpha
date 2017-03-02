import Axios from 'axios'
import * as moment from 'moment'
import * as querystring from 'querystring'
import * as mapbox from 'mapbox-gl'
import {ActionContext, Module} from 'vuex'

import {bsearch} from 'utilities/bsearch'
import {Datapoint, TimeRange} from '../index'
import {TelemetryResponse} from './telemetry'
import {RootState} from '../create'
import {findLast, forOwn, isNil, omit, sortBy} from "lodash-es";

export type Coordinate = [number, number, number | null]

export interface RouteState {
  routeTelemetry: Datapoint<Coordinate>[]
  newTelemetry: Datapoint<Coordinate>[]
  routeLoaded: boolean
  routeLoading: boolean
  routeError?: Error
  visibleRouteRegion?: TimeRange
  hoverTimestamp?: number
}

type FrozenRouteState = Omit<RouteState, 'routeError' | 'routeLoading'>

const state: () => RouteState = () => {
  return {
    routeTelemetry: [],
    newTelemetry: [],

    routeLoaded: false,
    routeLoading: false,
    routeError: null,

    visibleRouteRegion: null,
    hoverTimestamp: null
  }
}

const getters = {
  routeTelemetry(state: RouteState): Datapoint<Coordinate>[] {
    if (!state.routeLoaded) return []
    return sortBy(state.routeTelemetry, ([time]) => time)
  },
  routeCoordinates(state: RouteState, getters): Coordinate[] {
    return getters.routeTelemetry.reduce(
        (coords, [time, point]) => {
          if (point) coords.push(point)
          return coords
        }, [])
  },
  coordinateForTime(state: RouteState, getters): (timestamp: number) => Coordinate | null {
    return timestamp => {
      const result = bsearch(getters.routeTelemetry, timestamp, (([time]) => time), {inexact: true})
      if (!result || !result[1]) return null
      return result[1]
    }
  },
  routeLoading(state: RouteState): boolean { return state.routeLoading },
  routeError(state: RouteState): Error | null { return state.routeError },

  visibleRouteRegion(state: RouteState): TimeRange | null { return state.visibleRouteRegion },
  hoverTimestamp(state: RouteState): number | null { return state.hoverTimestamp },

  freezeRoute(state: RouteState): FrozenRouteState | null {
    if (state.routeLoading || !isNil(state.routeError)) return null
    return omit(state, ['routeError', 'routeLoading'])
  }
}

const mutations = {
  INITIALIZE_ROUTE(state: RouteState, {storedState}: {storedState: FrozenRouteState}) {
    forOwn(storedState, (v, k) => state[k] = v)
  },

  RESET_ROUTE_TELEMETRY(state: RouteState) {
    state.routeTelemetry = []
    state.newTelemetry = []
    state.routeLoaded = false
    state.routeError = null
    state.visibleRouteRegion = null
  },

  FINISH_ROUTE_TELEMETRY(state: RouteState, {telemetry}: {telemetry: {[parameter: string]: Datapoint<Coordinate>[]}}) {
    state.newTelemetry = telemetry['positions[any].position'].map(
        ([time, coordinate]) => {
          return [moment(time).unix()*1000, coordinate]
        })

    state.routeLoaded = true
    state.routeLoading = false
    state.routeTelemetry = state.newTelemetry
  },

  SET_ROUTE_ERROR(state: RouteState, {error}: {error: Error}) {
    state.routeTelemetry = []
    state.newTelemetry = []
    state.routeLoaded = true
    state.routeLoading = false
    state.routeError = error
  },

  START_ROUTE_TELEMETRY(state: RouteState) {
    state.newTelemetry = []
    state.routeLoading = true
  },

  SET_VISIBLE_ROUTE_REGION(state: RouteState, {region}: {region: TimeRange}) {
    state.visibleRouteRegion = region
  },

  SET_HOVER_TIMESTAMP(state: RouteState, {timestamp}: {timestamp: number}) {
    state.hoverTimestamp = timestamp
  }
}

const actions = {
  resetRouteTelemetry({commit}: ActionContext<RouteState, RootState>) {
    commit('RESET_ROUTE_TELEMETRY')
  },

  loadRouteTelemetry({commit, state}: ActionContext<RouteState, RootState>, {aircraftID, token, start, stop, force}: {aircraftID: string, token: string, start: string, stop: string, force: boolean}): Promise<boolean> {
    if (!force && state.routeLoaded) return Promise.resolve(false)
    commit('RESET_ROUTE_TELEMETRY')

    return new Promise<boolean>((resolve, reject) => {
      commit('START_ROUTE_TELEMETRY')
      const baseURL = `/aircraft/${aircraftID}/telemetry.json?`
      const params = {parameters: 'positions[any].position', token, start, stop}
      Axios.get<TelemetryResponse>(baseURL + querystring.stringify(params))
           .then(({data: {telemetry}}) => {
             commit('FINISH_ROUTE_TELEMETRY', {telemetry})
             resolve(true)
           }).catch(error => { commit('SET_ROUTE_ERROR', {error}); reject(error); })
    })
  },

  setMapBounds({commit, getters}: ActionContext<RouteState, RootState>, {bounds}: {bounds: mapbox.LngLatBounds}) {
    const inView = (lon, lat) => {
      if (bounds.getEast() > bounds.getWest()) {
        // bounds does not include the prime meridian
        return lat >= bounds.getSouth() && lat <= bounds.getNorth() &&
               lon >= bounds.getWest() && lon <= bounds.getEast()
      } else {
        // bounds includes the prime meridian
        return (lat >= bounds.getSouth() && lat <= bounds.getNorth()) &&
               (lon >= bounds.getWest() || lon <= bounds.getEast())
      }
    }
    const min = getters.routeTelemetry.find(([time, coords]) => coords && inView(coords[0], coords[1]))
    const max = findLast(getters.routeTelemetry, ([time, coords]) => coords && inView(coords[0], coords[1]))

    if (!min || !max) commit('SET_VISIBLE_ROUTE_REGION', {region: null})
    else commit('SET_VISIBLE_ROUTE_REGION', {region: [min[0], max[0]]})
  },

  setHoverTimestamp({commit}: ActionContext<RouteState, RootState>, {timestamp}: {timestamp: number}) {
    commit('SET_HOVER_TIMESTAMP', {timestamp})
  }
}

const route: Module<RouteState, RootState> = {state, getters, mutations, actions}
export default route
