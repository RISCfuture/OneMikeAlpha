<template>
  <form @submit.prevent="save" ref="form" :method="method" :action="action">
    <ul v-if="errors.base" class="errors">
      <li v-for="error in errors.base">{{error}}</li>
    </ul>
    <slot></slot>
  </form>
</template>

<script lang="ts">
  import Axios, {Method} from 'axios'
  import Vue from 'vue'
  import Component from 'vue-class-component'
  import {Prop, Watch} from 'vue-property-decorator'

  import SmartFormBus from './SmartFormBus'
  import SmartField from 'components/SmartForm/SmartField.vue'

  @Component
  export default class SmartForm extends Vue {
    @Prop({type: String, required: true}) action: string
    @Prop({type: String, default: 'post'}) method: Method
    @Prop({type: Object, required: true}) object: Record<string, string>
    @Prop({type: String, required: true}) objectName: string

    errors: Record<string, string[]> = {}

    get formData(): FormData {
      let formData = new FormData(this.$refs.form)
      this.$children.forEach(child => {
        if (child.type !== 'file') return
        if (child.buffer === '') return
        formData.append(child.field, child.buffer)
      })
      return formData
    }

    async save() {
      this.setInputsEnabled(false)
      SmartFormBus.$emit('submit')
      try {
        let response = await Axios.request({method: this.method, url: this.action, data: this.formData})
        this.setInputsEnabled(true)
        SmartFormBus.$emit('complete')
        SmartFormBus.$emit('success', response)
        this.$emit('complete')
        this.$emit('success', response)
      } catch (error) {
        this.setInputsEnabled(true)
        SmartFormBus.$emit('complete')
        SmartFormBus.$emit('error', error)
        this.$emit('complete')
        this.$emit('error', error)
        if (error.response.status === 422)
          this.errors = error.response.data.errors
      }
    }

    mounted() {
      SmartFormBus.$on('value-updated', (field, value) => this.object[field] = value)
      this.$children.forEach(child => child.object = this.object)
    }

    @Watch('object')
    onObjectChanged() {
      this.$children.forEach(child => child.object = this.object)
    }

    private setInputsEnabled(enabled: boolean) {
      this.$refs.form.querySelectorAll<HTMLInputElement>('input[type=submit], input[type=cancel], input[type=reset]').forEach(button => {
        button.disabled = !enabled
      })
    }
  }
</script>
