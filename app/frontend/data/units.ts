import * as Qty from 'js-quantities'
import { forOwn, identity, isArray } from "lodash-es";

export class UnitSystem {
  units: Map<string, string>
  static base = new Proxy(new UnitSystem(), {
    get(target, property: string, receiver): string {
      if (target.units.has(property))
        return target.units.get(property)
      else return target[property]
    },
    set(target, property: string, value: string): boolean {
      target.units.set(property, value)
      return true
    },
    has(target, property: string): boolean {
      return target.units.has(property)
    }
  })

  constructor(definitions?: Record<string, string>) {
    this.units = new Map()
    forOwn(definitions, (value, key) => this.units.set(key, value))
  }

  static defineBase(definitions: Record<string, string>) {
    forOwn(definitions, (value, key) => this.base[key] = value)
  }

  static new(...rest) {
    const system = new this(...rest)
    return new Proxy(system, system.proxy())
  }

  makeUnit(quantity: number, dimension: string): Qty {
    return Qty(quantity, this[dimension])
  }

  convertToSystem(quantity: Qty, dimension: string): Qty {
    if (!this[dimension]) return quantity
    if (this[dimension] === UnitSystem.base[dimension]) return quantity
    let value = quantity.to(this[dimension])

    // Quantities-JS incorrectly defines 1 g as 9.8 m/s^2 when it's actually -9.8
    // (acceleration through the floor, not the ceiling); let's fix that
    if (this[dimension] === 'gee')
      value = Qty(-value.scalar, value.units())

    return value
  }

  batchConverterToSystem(dimension: string): Qty.Converter {
    if (!this[dimension]) return identity
    if (this[dimension] === UnitSystem.base[dimension]) return identity

    let func = Qty.swiftConverter(UnitSystem.base[dimension], this[dimension])

    // Quantities-JS incorrectly defines 1 g as 9.8 m/s^2 when it's actually -9.8
    // (acceleration through the floor, not the ceiling); let's fix that
    if (this[dimension] === 'gee') {
      const converter = new class {
        convert(value: number): number
        convert(value: number[]): number[]
        convert(value: number | number[]): number | number[] {
          if (isArray(value)) {
            const result = func(value)
            return result.map(r => -r)
          } else {
            return -func(value)
          }
        }
      }

      return converter.convert
    } else return func
  }

  proxy(): ProxyHandler<this> {
    return {
      get(target, property: string, receiver): string {
        if (target.units.has(property))
          return target.units.get(property)
        else if (UnitSystem.base.units.has(property))
          return UnitSystem.base[property]
        else return target[property]
      },

      set(target, property: string, value: string): boolean {
        target.units.set(property, value)
        return true
      },

      has(target, property: string): boolean {
        return target.units.has(property) || UnitSystem.base.units.has(property)
      }
    }
  }
}

UnitSystem.defineBase({
  acceleration: 'm/s^2',
  air_pressure: 'Pa',
  air_temperature: 'tempK',
  air_temperature_difference: 'degK',
  altitude: 'm',
  angle: 'rad',
  current: 'A',
  distance: 'm',
  fuel_economy: 'm/kL',
  heading: 'rad',
  hf_frequency: 'Hz',
  mass: 'g',
  potential: 'V',
  rotational_velocity: 'rad/s',
  speed: 'm/s',
  system_pressure: 'Pa',
  temperature: 'tempK',
  time: 's',
  turn_rate: 'rad/s',
  vhf_uhf_frequency: 'Hz',
  volume: 'kL',
  volumetric_flow: 'kL/s'
})

export const unitsAmerican = UnitSystem.new({
  acceleration: 'gee',
  air_pressure: 'inHg',
  air_temperature: 'tempC',
  air_temperature_difference: 'celsius',
  altitude: 'ft',
  angle: 'deg',
  distance: 'nmi',
  fuel_economy: 'nmi/gal',
  heading: 'deg',
  hf_frequency: 'kHz',
  mass: 'lb',
  rotational_velocity: 'rpm',
  speed: 'kt',
  system_pressure: 'psi',
  temperature: 'tempF',
  time: 'min',
  turn_rate: 'deg/s',
  vhf_uhf_frequency: 'MHz',
  volume: 'gal',
  volumetric_flow: 'gal/hr'
})

export const unitsEuropean = UnitSystem.new({
  acceleration: 'gee',
  air_pressure: 'hPa',
  air_temperature: 'tempC',
  air_temperature_difference: 'celsius',
  altitude: 'ft',
  angle: 'deg',
  distance: 'nmi',
  fuel_economy: 'km/L',
  heading: 'deg',
  hf_frequency: 'kHz',
  mass: 'kg',
  rotational_velocity: 'rpm',
  speed: 'kt',
  system_pressure: 'bar',
  temperature: 'tempC',
  time: 'min',
  turn_rate: 'deg/s',
  vhf_uhf_frequency: 'MHz',
  volume: 'gal',
  volumetric_flow: 'L/hr'
})

export const unitsEastern = UnitSystem.new({
  acceleration: 'gee',
  air_pressure: 'torr',
  air_temperature: 'tempC',
  air_temperature_difference: 'celsius',
  altitude: 'm',
  angle: 'deg',
  distance: 'km',
  fuel_economy: 'km/L',
  heading: 'deg',
  mass: 'kg',
  rotational_velocity: 'rpm',
  speed: 'km/hr',
  system_pressure: 'bar',
  temperature: 'tempC',
  turn_rate: 'deg/s',
  volume: 'gal',
  volumetric_flow: 'L/hr',
  time: 'min'
})

export function unitI18nKey(unit: Qty) {
  return unit.units()
      .replace(/\//g, '_per_').replace(/^2/g, '_sq')
}
