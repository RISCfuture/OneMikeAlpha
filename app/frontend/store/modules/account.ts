import {ActionContext, Module} from 'vuex'
import Axios, {AxiosResponse} from 'axios'

import {RootState} from '../create'
import Secrets from "config/secrets.js";
import * as querystring from "querystring";
import { createConsumer } from "@rails/actioncable"
import {forOwn, isNull} from "lodash-es";

export interface AccountState {
  JWT?: string
}

interface JWTPayload {
  iss: string
  sub: string
  aud: string
  exp?: string | number
  nbf?: string | number
  iat: string | number
  jti: string

  email: string
}

const state: AccountState = {
  JWT: null
}

const getters = {
  JWT(state: AccountState): string | null { return state.JWT },
  JWTPayload(state: AccountState): JWTPayload | null { return state.JWT ? JSON.parse(atob(state.JWT.split('.')[1])) : null },

  loggedIn(state: AccountState): boolean { return !isNull(state.JWT) },

  currentUserEmail(state: AccountState, getters: any): string | null {
    const payload: JWTPayload | null = getters.JWTPayload
    if (isNull(payload)) return null
    return payload.email
  },

  authHeader(state: AccountState): string | null {
    if (state.JWT)
      return `Bearer ${state.JWT}`
    else
      return null
  },

  freezeAccount(state: AccountState): AccountState { return state },

  actionCableConsumer(state: AccountState): ActionCable.Cable | null {
    if (isNull(state.JWT)) return null
    const URL = `${Secrets.actionCableURL}?${querystring.stringify({jwt: state.JWT})}`
    return createConsumer(URL)
  }
}

const mutations = {
  INITIALIZE_ACCOUNT(state: AccountState, {storedState}: {storedState: AccountState}) {
    forOwn(storedState, (v, k) => state[k] = v)
  },

  SET_JWT(state: AccountState, {JWT}: {JWT?: string}) {
    state.JWT = JWT
  }
}

const actions = {
  async login({commit, dispatch}: ActionContext<AccountState, RootState>, {email, password}: {email: string, password: string}): Promise<void> {
    const response = await Axios.post<string>('/login.json', {user: {email, password}})
    dispatch('setJWT', {response})
  },

  setJWT({commit}: ActionContext<AccountState, RootState>, {response}: {response: AxiosResponse}) {
    if (response.headers['authorization'] && response.headers['authorization'].match(/^Bearer /))
      commit('SET_JWT', {JWT: response.headers['authorization'].slice(7)})
  },

  async logout({commit}: ActionContext<AccountState, RootState>): Promise<void> {
    commit('SET_JWT', {JWT: null})
  }
}

const account: Module<AccountState, RootState> = {state, getters, mutations, actions}
export default account
