<template>
  <div class="field-error-pair">
    <textarea v-if="type === 'textarea'"
              v-bind="commonAttributes"
              v-model="buffer"
              ref="field"
              @focus="onFocus()"
              @blur="onBlur()"
              @change="onChange()" />

    <select v-else-if="type === 'select'"
            v-bind="commonAttributes"
            v-model="buffer"
            ref="field"
            @focus="onFocus()"
            @blur="onBlur()"
            @change="onChange()">
      <slot />
    </select>

    <label v-else-if="type === 'checkbox'"
           class="checkbox-label">
      <input v-bind="commonAttributes"
             v-model="buffer"
             ref="field"
             :type="type"
             @focus="onFocus()"
             @blur="onBlur()"
             @change="onChange()" />
      <slot />
    </label>

    <input v-else
           v-bind="commonAttributes"
           v-model="buffer"
           ref="field"
           :type="type"
           @focus="onFocus()"
           @blur="onBlur()"
           @change="onChange()" />

    <ul v-if="errors.length > 0" class="errors">
      <li v-for="error in errors">{{error}}</li>
    </ul>
  </div>
</template>

<script lang="ts">
  import Vue from 'vue'
  import Component from 'vue-class-component'
  import {Prop, Watch} from 'vue-property-decorator'

  import SmartFormBus from './SmartFormBus'
  import SmartForm from 'components/SmartForm/SmartForm.vue'

  @Component({
    inheritAttrs: false
  })
  export default class SmartField<FormObject> extends Vue {
    $parent!: SmartForm<FormObject>
    $refs!: {
      field: HTMLTextAreaElement | HTMLSelectElement | HTMLInputElement
    }

    object?: FormObject = null
    buffer = ''

    @Prop({type: String, default: 'text'}) type: string
    @Prop({type: String, required: true}) field: string

    private get name(): string { return `${this.$parent.objectName}[${this.field}]` }
    private get id(): string { return `${this.$parent.objectName}_${this.field}` }
    get errors(): string[] { return this.$parent.errors[this.field] || [] }
    private get invalid(): boolean { return this.errors.length > 0 }

    get commonAttributes() {
      return {
        name: this.name,
        id: this.id,
        class: {invalid: this.invalid},
        'v-model': this.buffer,
        ...this.$attrs
      }
    }
    onFocus() { SmartFormBus.$emit('field-focus', this.field) }
    onBlur() { SmartFormBus.$emit('field-blur', this.field) }
    onChange() { SmartFormBus.$emit('value-updated', this.field, this.buffer) }

    focus() {
      this.$refs.field.focus()
    }

    @Watch('object')
    onObjectChanged() {
      if (this.type === 'file') return
      this.buffer = this.object[this.field]
    }

    @Watch('buffer')
    onBufferChanged() {
      this.onChange()
    }
  }
</script>
