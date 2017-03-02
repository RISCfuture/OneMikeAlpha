import Axios from 'axios'
import * as moment from 'moment'
import * as querystring from 'querystring'
import {ActionContext, Module} from 'vuex'

import {Flight, Upload} from 'types'
import {RootState} from '../create'
import {setToJSONObject} from '../utilities'
import {clone, isNil, map, max, min, pickBy, sortBy} from "lodash-es";
import {UploadsState} from "./uploads";

export interface FlightsState {
  flights: Flight[]
  flightsLoadingStack: number
  flightsError: Error | null
  loadedFlightsLowerThan: Set<number>
  loadedFlightsHigherThan: Set<number>
  flightsSubscription: ActionCable.Channel | null
}

export interface FlightGroup {
  date: string,
  flights: Flight[]
}

interface FrozenFlightsState {
  flights: Flight[]
  loadedFlightsLowerThan: Array<number>
  loadedFlightsHigherThan: Array<number>
}

type SubscribedFlight = Flight & {destroyed?: boolean}

const state: () => FlightsState = () => {
  return {
    flights: [],
    flightsLoadingStack: 0,
    flightsError: null,
    loadedFlightsLowerThan: new Set(),
    loadedFlightsHigherThan: new Set(),
    flightsSubscription: null
  }
}

const getters = {
  flights(state: FlightsState): Flight[] { return state.flightsLoadingStack ? [] : state.flights },
  flightsLoading(state: FlightsState): boolean { return state.flightsLoadingStack > 0 },
  flightsError(state: FlightsState): Error | null { return state.flightsError },

  flightByID(state: FlightsState): (ID: string) => Flight | null { return ID => state.flights.find(f => f.id === ID) },
  flightsByDate(state: FlightsState): FlightGroup[] {
    const map = state.flights.reduce((groups, flight) => {
      const day = moment(flight.departure_time).startOf('day').format()
      if (!groups.has(day)) groups.set(day, [])
      groups.get(day).push(flight)
      return groups
    }, new Map<string, Flight[]>())
    const flightsByDate: FlightGroup[] = []
    map.forEach((flights, date) => flightsByDate.push({date, flights}))
    return flightsByDate
  },

  freezeFlights(state: FlightsState): FrozenFlightsState | null {
    if (state.flightsLoadingStack !== 0 || !isNil(state.flightsError)) return null
    return {
      flights: state.flights,
      loadedFlightsLowerThan: setToJSONObject(state.loadedFlightsLowerThan),
      loadedFlightsHigherThan: setToJSONObject(state.loadedFlightsHigherThan)
    }
  }
}

const mutations = {
  INITIALIZE_FLIGHTS(state: FlightsState, {storedState}: {storedState: FrozenFlightsState}) {
    state.flights = storedState.flights
    state.loadedFlightsLowerThan = new Set(storedState.loadedFlightsLowerThan)
    state.loadedFlightsHigherThan = new Set(storedState.loadedFlightsHigherThan)
  },

  RESET_FLIGHTS(state: FlightsState) {
    state.flights = []
    state.flightsLoadingStack = 0
    state.flightsError = null
    state.loadedFlightsLowerThan = new Set()
    state.loadedFlightsHigherThan = new Set()
  },

  START_FLIGHTS(state: FlightsState) {
    state.flightsLoadingStack++
  },

  APPEND_FLIGHTS(state: FlightsState, {flights}: {flights: Flight[]}) {
    if (state.flightsLoadingStack === 0) return // RESET_FLIGHTS called in the interim

    state.flights = state.flights.concat(flights)
    state.flights = sortBy(state.flights, [f => -f.sort_key])
    state.flightsLoadingStack--
  },

  ADD_LOWER(state: FlightsState, {ID}: {ID: number}) {
    state.loadedFlightsLowerThan = clone(state.loadedFlightsLowerThan.add(ID))
  },

  ADD_HIGHER(state: FlightsState, {ID}: {ID: number}) {
    state.loadedFlightsHigherThan = clone(state.loadedFlightsHigherThan.add(ID))
  },

  CREATE_FLIGHTS_CONSUMER(
      state: FlightsState,
      {aircraftID, consumer}: {aircraftID: number, consumer: ActionCable.Cable}
  ) {
    if (state.flightsSubscription) state.flightsSubscription.unsubscribe()
    state.flightsSubscription = consumer.subscriptions.create({
      channel: 'FlightsChannel',
      id: aircraftID,
    }, {
      received(flight: SubscribedFlight) {
        let index = state.flights.findIndex(f => f.id === flight.id)

        let newFlights
        if (flight.destroyed)
          newFlights = [...state.flights.slice(0, index-1), ...state.flights.slice(index+1)]
        else
          newFlights = [...state.flights.slice(0, index-1), flight, ...state.flights.slice(index+1)]

        state.flights = sortBy(newFlights, [f => -moment(flight.departure_time).unix()])
        //TODO handle filtering and other sorting
      }
    })
  },

  SET_FLIGHTS_ERROR(state: FlightsState, {error}: {error: Error}) {
    state.flights = []
    state.flightsError = error
    state.flightsLoadingStack--
  }
}

const actions = {
  clearFlights({commit}: ActionContext<FlightsState, RootState>) {
    commit('RESET_FLIGHTS')
  },

  loadFlight({commit, state}: ActionContext<FlightsState, RootState>, {aircraftID, flightID}: {aircraftID: string, flightID: string}): Promise<Flight | null> {
    const URL = `/aircraft/${aircraftID}/flights/${flightID}.json`

    return new Promise((resolve, reject) => {
      commit('START_FLIGHTS')
      Axios.get<Flight>(URL).then(({data: flight}) => {
        if (state.flightsLoadingStack === 0) resolve(null)
        else {
          commit('APPEND_FLIGHTS', {flights: [flight]})
          resolve(flight)
        }
      }).catch(error => {
        commit('SET_FLIGHTS_ERROR', {error})
        reject(error)
      })
    })
  },

  loadFlights(
      {commit, state, rootGetters}: ActionContext<FlightsState, RootState>,
      {aircraftID, params}: {aircraftID: string, params: Record<string, string>}
  ): Promise<Flight[] | null> {
    const baseURL = `/aircraft/${aircraftID}/flights.json?`
    params = pickBy(params)

    return new Promise((resolve, reject) => {
      commit('START_FLIGHTS')
      Axios.get<Flight[]>(baseURL + querystring.stringify(params))
           .then(({data: flights}) => {
             if (state.flightsLoadingStack === 0) resolve(null)
             else {
               commit('APPEND_FLIGHTS', {flights})
               if (rootGetters.actionCableConsumer)
                 commit('CREATE_FLIGHTS_CONSUMER', {
                   aircraftID,
                   consumer: rootGetters.actionCableConsumer
                 })
               resolve(flights)
             }
           })
           .catch(error => {
             commit('SET_FLIGHTS_ERROR', {error})
             reject(error)
           })
    })
  },

  loadFlightsWithIDLowerThan(
      {commit, state, dispatch}: ActionContext<FlightsState, RootState>,
      {aircraftID, force, filter, ID}:
          {aircraftID: string, force?: boolean, filter?: string, ID?: number}
  ): Promise<number | null> {
    if (!force && state.loadedFlightsLowerThan.has(ID)) return Promise.resolve(ID)
    commit('ADD_LOWER', {ID: ID})

    return new Promise<number>((resolve, reject) => {
      let IDString = ID.toFixed(6)
      dispatch('loadFlights', {aircraftID, params: {filter, sort: 'time', dir: 'desc', id: IDString}}).then(flights => {
        if (!flights) {
          resolve(null)
          return
        }
        const lowestSortKey = min(map(flights, f => Number(f.sort_key)))
        resolve(lowestSortKey)
      }).catch(e => reject(e))
    })
  },

  loadFlightsWithIDHigherThan(
      {commit, state, dispatch}: ActionContext<FlightsState, RootState>,
      {aircraftID, force, filter, ID}:
          {aircraftID: string, force?: boolean, filter?: string, ID?: number}
  ): Promise<number | null> {
    if (!force && state.loadedFlightsHigherThan.has(ID)) return Promise.resolve(ID)
    commit('ADD_HIGHER', {ID: ID})

    return new Promise<number>((resolve, reject) => {
      let IDString = ID.toFixed(6)
      dispatch('loadFlights', {aircraftID, params: {filter, sort: 'time', dir: 'asc', id: IDString}}).then(flights => {
        if (!flights) {
          resolve(null)
          return
        }
        const highestSortKey = max(map(flights, f => Number(f.sort_key)))
        resolve(highestSortKey)
      }).catch(e => reject(e))
    })
  }
}

const flights: Module<FlightsState, RootState> = {state, getters, mutations, actions}
export default flights
