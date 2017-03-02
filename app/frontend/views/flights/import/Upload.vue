<template>
  <div class="upload">
    <div class="file-image"><file-image :class="{failure: uploadFailed}" /></div>
    <p>
      <span class="filename">{{fileName}}</span><br />
      {{upload.created_at | timeAgoFormatter}}
    </p>
  </div>
</template>

<script lang="ts">
  import Vue from 'vue'
  import Component from 'vue-class-component'
  import {Prop} from 'vue-property-decorator'
  import * as numeral from 'numeral'
  import * as moment from 'moment'

  import * as Types from 'types'
  import i18n from 'config/i18n'
  import FileImage from 'images/File'

  @Component({
    components: {FileImage},
    filters: {
      timeAgoFormatter(dateString: string): string {
        const date = moment(dateString)
        if (date.isAfter(moment().subtract(2, 'days')))
          return date.fromNow()
        else
          return date.format(<string>i18n.t('date.dateOnlyMedium'))
      }
    }
  })
  export default class Upload extends Vue {
    @Prop({type: Object}) upload: Types.Upload

    get uploadFailed(): boolean { return this.upload.state === Types.UploadState.Failed }

    get fileName(): string {
      if (this.upload.files.length === 0)
        return "<no files>"
      else if (this.upload.files.length === 1)
        return this.upload.files[0].filename
      else
        return <string>this.$t('views.flights.import.upload.multipleFiles', {
          name: this.upload.files[0].filename,
          count: numeral(this.upload.files.length).format(<string>this.$t('number.integer'))
        })
    }
  }
</script>

<style lang="scss" scoped>
  .upload {
    display: flex;
    flex-flow: row nowrap;
    justify-content: center;
    align-items: center;

    &:not(:last-child) {
      margin-bottom: 10px;
    }
  }

  .file-image {
    flex: 0 0 auto;
    margin-right: 10px;

    svg {
      width: 20px;
      height: auto;
    }
  }

  p {
    flex: 1 1 auto;
    margin: 0;

    span.filename {
      font-weight: bold;
    }
  }

</style>
