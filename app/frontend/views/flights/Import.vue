<template>
  <div class="imports">
    <div v-if="incompleteUploads.length" class="uploads">
      <upload v-for="upload in incompleteUploads" :key="upload.id" :upload="upload" />
    </div>
    <form method="POST" :action="APIURL" ref="form">
      <input @change="uploadsChosen"
             multiple
             name="upload[files]"
             ref="fileField"
             type="file" />
      <input :value="uploadButtonTitle"
             @click.prevent="addUpload"
             name="commit"
             type="submit" />
    </form>
  </div>
</template>

<script lang="ts">
  import Component, {mixins} from 'vue-class-component'
  import {Action, Getter} from 'vuex-class'
  import {Watch} from 'vue-property-decorator'
  import Axios from 'axios'

  import * as Types from 'types'
  import Upload from './import/Upload'
  import CurrentRoute from 'mixins/CurrentRoute'
  import Channel = ActionCable.Channel

  @Component({
    components: {Upload}
  })
  export default class Import extends mixins(CurrentRoute) {
    $refs!: {
      form: HTMLFormElement
      fileField: HTMLInputElement
    }

    uploadsSubscription: Channel

    @Getter actionCableConsumer: ActionCable.Cable
    @Getter incompleteUploads: Types.Upload[]

    get APIURL(): string { return `/aircraft/${this.currentAircraftID}/uploads.json` }

    get uploadButtonTitle(): string {
      if (this.incompleteUploads.length)
        return <string>this.$t('views.flights.import.addMoreUploads')
      else
        return <string>this.$t('views.flights.import.addUpload')
    }

    @Action loadUploads: (params: {aircraftID: string}) => Promise<boolean>

    addUpload() {
      this.$refs.fileField.click()
    }

    async uploadsChosen() {
      const files = this.$refs.fileField.files;
      if (files.length === 0) return

      const data = new FormData()
      for (let i = 0; i !== files.length; i++)
        data.append('upload[files][]', files[i])

      await Axios.post(this.APIURL, data)
      this.loadUploads({aircraftID: this.currentAircraftID})
    }

    mounted() {
      if (this.currentAircraftID) this.loadUploads({aircraftID: this.currentAircraftID})
      this.createUploadsSubscription()
    }

    destroyed() {
      if (this.uploadsSubscription) this.uploadsSubscription.unsubscribe()
    }

    @Watch('currentAircraftID')
    onCurrentAircraftIDChanged() {
      this.loadUploads({aircraftID: this.currentAircraftID})
      this.createUploadsSubscription()
    }

    private createUploadsSubscription() {
      if (this.uploadsSubscription) this.uploadsSubscription.unsubscribe()
      this.uploadsSubscription = this.actionCableConsumer.subscriptions.create({
        channel: 'UploadsChannel',
        id: this.currentAircraftID,
      }, {
        connected() {
          console.log(1)
        },
        disconnected() {
          console.log(2)
        },
        received(data) {
          console.log(data)
        }
      })
    }
  }
</script>

<style lang="scss" scoped>
  @import "../../stylesheets/config.scss";

  .imports {
    max-height: 50vh;
    overflow-y: scroll;
  }

  .uploads {
    max-height: 300px;
    overflow-y: auto;
    border-bottom: 1px solid $medium-gray;
    margin-bottom: 0.5em;
  }

  form {
    text-align: center;
  }

  input[type=file] {
    display: none;
  }
</style>
