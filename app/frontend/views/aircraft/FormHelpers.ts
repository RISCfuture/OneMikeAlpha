import Vue from 'vue'
import Component from 'vue-class-component'
import {isEmpty, reduce, reject} from "lodash-es";

interface Type {
  id: string
  name: string
}

interface Manufacturer {
  name: string
  types: Type[]
}

interface I18nTypes {
  [manufacturer: string]: {
    [key: string]: string
  }
}

@Component
export default class FormHelpers extends Vue {
  get aircraftTypes(): Manufacturer[] {
    const i18nTypes = <I18nTypes>this.$t('types.aircraft', {returnObjects: true})
    return reduce(i18nTypes,
        (list, types, manufacturer) => {
          const mappedTypes = reduce(types,
              (list, value, key) => {
                list.push({id: key, name: value})
                return list
              },
              [])
          list.push({name: manufacturer, types: mappedTypes})
          return list
        },
        []
    )
  }

  get equipmentTypes(): Manufacturer[] {
    const i18nTypes = <I18nTypes>this.$t('types.equipment', {returnObjects: true})
    return reduce(i18nTypes,
        (list, types, manufacturer) => {
          const mappedTypes = reduce(types,
              (list, value, key) => {
                list.push({id: key, name: value})
                return list
              },
              [])
          list.push({name: manufacturer, types: mappedTypes})
          return list
        },
        []
    )
  }

  get permissionLevels(): [string, string][] {
    return reduce(<object>this.$t(`aircraft.permissionLevels`, {returnObjects: true}),
        (array, name, id) => {
          array.push([id, name])
          return array
        }, [])
  }

  get newPermissionLevels(): [string, string][] {
    return reject(this.permissionLevels, ([id, name]) => isEmpty(id))
  }
}
