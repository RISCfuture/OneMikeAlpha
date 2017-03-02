import VueI18n from 'vue-i18n'
import * as moment from 'moment'
const momentDurationFormatSetup = require('moment-duration-format')
momentDurationFormatSetup(moment)
import * as numeral from 'numeral'

import i18n from 'config/i18n'
import {isString} from "lodash-es";

export function t(key: VueI18n.Path, ...rest): string {
  const result = i18n.t(key, ...rest)
  if (isString(result)) return result
  else throw new Error(`Expected translation for ${key} to be string, but was not`)
}

export function formatValue(value: number, format?: string, duration?: moment.unitOfTime.DurationConstructor): string {
  if (!format) return numeral(value).format()

  if (duration) {
    const durationObj = moment.duration(value, duration)
    return durationObj.format(format)
  }
  else {
    // number
    const number = numeral(value)
    let result = format.replace(/{(.+?)}/,
        (_match, format) => number.format(format))
    result = result.replace(/\[-(.+?)\+(.+?)]/,
        (_match, neg, pos) => (value >= 0 ? pos : neg))
    return result
  }
}
