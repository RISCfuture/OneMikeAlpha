<template>
  <div v-if="hasContent" class="content-container">
    <slot />
  </div>

  <article class="no-content-container" v-else>
    <spinner v-if="loading" />
    <p v-else-if="errorNot404" class="big-help error">{{error | errorFormatter}}</p>
    <p v-else-if="noContentMessage" class="big-help">{{noContentMessage}}</p>
    <slot name="no-content" v-else />
  </article>
</template>

<script lang="ts">
  import Vue from 'vue'
  import Component from 'vue-class-component'
  import {Prop} from 'vue-property-decorator'
  import {AxiosError} from 'axios'

  @Component({
    filters: {
      errorFormatter(error: Error): string { return error.toLocaleString() }
    }
  })
  export default class ContentContainer extends Vue {
    @Prop({type: Boolean, required: true}) hasContent: boolean
    @Prop({type: Boolean, required: true}) loading: boolean
    @Prop({type: [Error, Object]}) error?: Error //TODO not sure why some errors are not Errors
    @Prop({type: String}) noContentMessage?: string

    get errorNot404(): Error | null {
      if (!this.error) return null
      if ((this.error as AxiosError).response) {
        if ((this.error as AxiosError).response.status === 404)
          return null
        else return this.error
      } else return this.error
    }
  }
</script>

<style lang="scss" scoped>
  .no-content-container {
    width: 100%;

    .uil-default-css {
      width: 100px;
      height: 100px;
      margin-left: auto;
      margin-right: auto;
      text-align: center;
      top: calc(50vh - 100px / 2);
    }

    p.big-help {
      width: 100%;
    }
  }
</style>
