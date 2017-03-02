import Vuex, {ModuleTree, StoreOptions} from 'vuex'
import createLogger from 'vuex/dist/logger'
import {capitalize, has} from "lodash-es";

const FROZEN_MODULES = ['account', 'settings']

const debug = process.env.NODE_ENV !== 'production' && !navigator.userAgent.includes("Chrome")

export interface RootState {
  // no root properties
}

export default function createStore(modules: ModuleTree<RootState>) {
  const storeOptions: StoreOptions<RootState> = {
    actions: {
      initialize({commit}) {
        if (localStorage.getItem('store')) {
          const storedState = JSON.parse(localStorage.getItem('store'))
          FROZEN_MODULES.forEach(mod => {
            if (has(storedState, mod))
              commit('INITIALIZE_' + mod.toUpperCase(), {storedState: storedState[mod]})
          })
        }
      }
    },

    modules,
    strict: debug,
    plugins: debug ? [createLogger()] : []
  }

  const store = new Vuex.Store<RootState>(storeOptions)

  store.subscribe((mutation, state) => {
    let frozenState = {}
    FROZEN_MODULES.forEach(mod => {
      const frozenMod = store.getters['freeze' + capitalize(mod)]
      if (frozenMod) frozenState[mod] = frozenMod
    })
    localStorage.setItem('store', JSON.stringify(frozenState))
  })

  return store
}
