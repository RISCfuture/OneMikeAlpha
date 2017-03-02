import {ActionContext, GetterTree, Module} from 'vuex'
import * as moment from 'moment'
import Axios from 'axios'

import {Upload, UploadState} from 'types'
import {RootState} from '../create'
import {isNil, sortBy} from "lodash-es";

export interface UploadsState {
  uploads: Upload[]
  uploadsLoading: boolean
  uploadsError?: Error
}

interface FrozenUploadsState {
  uploads: Upload[]
}

const state: () => UploadsState = () => {
  return {
    uploads: [],
    uploadsLoading: false,
    uploadsError: null
  }
}

const getters = {
  uploads(state: UploadsState): Upload[] { return state.uploadsLoading ? [] : state.uploads },
  uploadsLoading(state: UploadsState): boolean { return state.uploadsLoading },
  uploadsError(state: UploadsState): Error | null { return state.uploadsError },

  incompleteUploads(state: UploadsState, getters: any): Upload[] { return getters.uploads.filter(upload => upload.state !== UploadState.Finished) },

  freezeUploads(state: UploadsState): FrozenUploadsState | null {
    if (state.uploadsLoading || !isNil(state.uploadsError)) return null
    return {
      uploads: state.uploads
    }
  }
}

const mutations = {
  INITIALIZE_UPLOADS(state: UploadsState, {storedState}: {storedState: FrozenUploadsState}) {
    state.uploads = storedState.uploads
  },

  RESET_UPLOADS(state: UploadsState) {
    state.uploads = []
    state.uploadsError = null
  },

  START_UPLOADS(state: UploadsState) {
    state.uploadsLoading = true
  },

  APPEND_UPLOADS(state: UploadsState, {uploads}: {uploads: Upload[]}) {
    state.uploads = state.uploads.concat(uploads)
  },

  FINISH_UPLOADS(state: UploadsState) {
    state.uploads =  sortBy(state.uploads, [u => -moment(u.created_at).unix()])
    state.uploadsLoading = false
  },

  SET_UPLOADS_ERROR(state: UploadsState, {error}: {error: Error}) {
    state.uploads = []
    state.uploadsError = error
    state.uploadsLoading = false
  }
}

const actions = {
  loadUploads({commit, state}: ActionContext<UploadsState, RootState>, {aircraftID}: {aircraftID: string}): Promise<boolean> {
    if (state.uploadsLoading) return Promise.resolve(false)

    const rootURL = `/aircraft/${aircraftID}/uploads.json`

    return new Promise((resolve, reject) => {
      commit('START_UPLOADS')
      Axios.get(rootURL).then(({data: uploads, headers}) => {
        commit('RESET_UPLOADS')
        commit('APPEND_UPLOADS', {uploads})

        const pages = Number.parseInt(headers['x-pages'])
        let promises = []
        for (let page = 2; page <= pages; page++) {
          promises.push(Axios.get(rootURL + `?page=${page}`)
                             .then(({data: uploads}) => commit('APPEND_UPLOADS', {uploads})))
        }
        Promise.all(promises)
            .then(() => { commit('FINISH_UPLOADS'); resolve(true); })
            .catch(error => { commit('SET_UPLOADS_ERROR', {error}); reject(error); })
      }).catch(error => { commit('SET_UPLOADS_ERROR', {error}); reject(error); })
    })
  }
}

const uploads: Module<UploadsState, RootState> = {state, getters, mutations, actions}
export default uploads
