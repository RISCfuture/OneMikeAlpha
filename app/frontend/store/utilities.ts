import {Datapoint, TimeRange} from './index'
import * as moment from 'moment'
import {
  cloneDeep, each,
  find,
  findLast,
  get,
  has,
  isEmpty,
  remove,
  some
} from "lodash-es";

function quantizeInterval(interval: number): number { return Math.ceil(interval/10)*10 }

const DATAPOINTS_PER_WINDOW = 1000 //TODO sync with backend
export function calculateInterval(min: number, max: number): number {
  const interval = (((max - min)/1000)/DATAPOINTS_PER_WINDOW)
  return quantizeInterval(interval)
}

export function unloadedRange(loadedRanges: Map<number, TimeRange[]> = new Map(), interval: number, min: number, max: number): TimeRange {
  const ranges = loadedRanges.get(interval) || []
  const rangeOverlappingStart = find(ranges, ([begin, end]) => (begin <= min && end >= min))
  const unloadedRangeStart = (rangeOverlappingStart ? rangeOverlappingStart[1] : min)
  const rangeOverlappingEnd = findLast(ranges, ([begin, end]) => (begin <= max && end >= max))
  const unloadedRangeEnd = (rangeOverlappingEnd ? rangeOverlappingEnd[1] : max)

  if (unloadedRangeStart >= max || unloadedRangeEnd <= min) return null
  else return [unloadedRangeStart, unloadedRangeEnd]
}

export function chartDatasetsForParameter<DatapointValueType>(telemetry: Map<number, Datapoint<DatapointValueType>[]> = new Map(), loadedRanges: Map<number, TimeRange[]> = new Map(), minInterval: number): Datapoint<DatapointValueType>[] {
  let dataset: Datapoint<DatapointValueType>[] = []
  // progress from lowest interval to highest
  Array.from(telemetry.keys()).sort((a, b) => b - a).forEach(interval => {
    if (interval < minInterval) return false
    // find the ranges of the data we have for this interval
    const ranges = loadedRanges.get(interval) || []
    // delete all the data we already have in these ranges (at a lower resolution)
    remove(dataset, ([time]) => some(ranges, r => time >= r[0] && time <= r[1] ))
    // merge in the new data at this higher resolution
    const dataToMerge = telemetry.get(interval)
    let newDataset: Datapoint<DatapointValueType>[] = []
    let datasetIterator = 0, dataToMergeIterator = 0
    while (true) {
      if (dataToMergeIterator === dataToMerge.length) {
        newDataset = newDataset.concat(dataset.slice(datasetIterator))
        break
      }
      if (datasetIterator === dataset.length) {
        newDataset = newDataset.concat(dataToMerge.slice(dataToMergeIterator))
        break
      }

      if (dataToMerge[dataToMergeIterator][0] <= dataset[datasetIterator][0]) { // <= because we favor the new, higher-resolution data
        newDataset.push(dataToMerge[dataToMergeIterator])
        dataToMergeIterator++
      } else {
        newDataset.push(dataset[datasetIterator])
        datasetIterator++
      }
    }
    dataset = newDataset
  })
  return dataset
}

export function mergeTelemetry<DatapointType>(telemetry: Map<string, Map<number, DatapointType[]>>, newTelemetry: Record<string, DatapointType[]>, interval: number, timeRange: TimeRange): Map<string, Map<number, DatapointType[]>> {
  const quantizedInterval = quantizeInterval(interval)
  let newTelemetryByColumn = new Map<string, Map<number, DatapointType[]>>()

  // copy over old data that's not part of this update
  telemetry.forEach((oldIntervals, oldParameter) => {
    if (has(newTelemetry, oldParameter)) {
      newTelemetryByColumn.set(oldParameter, new Map())
      oldIntervals.forEach((oldData, oldInterval) => {
        if (oldInterval === quantizedInterval) newTelemetryByColumn.get(oldParameter).set(oldInterval, [])
        else newTelemetryByColumn.get(oldParameter).set(oldInterval, cloneDeep(oldData))
      })
    } else
      newTelemetryByColumn.set(oldParameter, new Map(oldIntervals))
  })

  // copy over new data from this update, merging with old data outside of new range
  each(newTelemetry, (newTelemetryForParameter, parameter) => {
    const oldTelemetry = get(telemetry, [parameter, quantizedInterval], [])
    let newData = new Array<DatapointType>()
    // add everything to the left of the new range
    oldTelemetry.forEach(pair => {
      if (pair[0] < timeRange[0]) newData.push(pair)
      else return false
    })

    // add the new data
    newData = newData.concat(newTelemetryForParameter)

    // add everything to the right of the new range
    oldTelemetry.forEach(pair => {
      if (pair[0] > timeRange[1]) newData.push(pair)
    })

    if (!newTelemetryByColumn.has(parameter)) newTelemetryByColumn.set(parameter, new Map())
    newTelemetryByColumn.get(parameter).set(quantizedInterval, newData)
  })

  return newTelemetryByColumn
}

export function updateRanges(loadedRanges: Map<string, Map<number, TimeRange[]>>, parameters: string[], [newStartTime, newStopTime]: TimeRange, interval: number): Map<string, Map<number, TimeRange[]>> {
  const newStart = moment(newStartTime).unix()*1000
  const newStop = moment(newStopTime).unix()*1000
  const quantizedInterval = quantizeInterval(interval)

  let newRanges = new Map<string, Map<number, TimeRange[]>>()
  loadedRanges.forEach((oldRanges, oldParameter) => {
    if (!parameters.includes(oldParameter)) newRanges.set(oldParameter, oldRanges)
  })

  parameters.forEach(parameter => {
    const oldRanges = (loadedRanges.get(parameter) || new Map<number, TimeRange[]>()).get(quantizedInterval)
    let newRangesForParameter: TimeRange[]
    if (isEmpty(oldRanges)) {
      newRangesForParameter = [[newStart, newStop]]
    } else {
      newRangesForParameter = oldRanges.reduce((result, [start, stop]) => {
        if (start < newStart && stop < newStart) result.push([start, stop])
        else if (start > newStop && stop > newStop) result.push([start, stop])
        else
          result.push([Math.min(start, newStart), Math.max(stop, newStop)])
        return result
      }, [])
    }
    if (!newRanges.has(parameter)) newRanges.set(parameter, new Map<number, TimeRange[]>())
    newRanges.get(parameter).set(quantizedInterval, newRangesForParameter)
  })

  return newRanges
}

type JSONPrimitive = string | number | boolean | null
type JSONValue = JSONPrimitive | JSONObject | JSONArray
type JSONObject = { [member: string]: JSONValue }
interface JSONArray extends Array<JSONValue> {}

type Freezable = FreezableMap | FreezableSet | JSONValue
interface FreezableMap extends Map<JSONPrimitive, Freezable> {}
interface FreezableSet extends Set<Freezable> {}

type Frozen<T> =
    T extends Map<infer K, infer V> ?
        (K extends JSONPrimitive ?
            V extends Freezable ?
                FrozenMap<K, V> :
                never :
            never) :
    T extends Set<infer U> ?
        (U extends Freezable ?
            FrozenSet<U> :
            never) :
    T extends JSONValue ?
        T :
        never
interface FrozenMap<K extends JSONPrimitive, V extends Freezable> extends Array<[K, Frozen<V>]> {}
interface FrozenSet<T extends Freezable> extends Array<Frozen<T>> {}

export function mapToJSONObject<K extends JSONPrimitive, V extends Freezable>(map: Map<K, V>): Array<[K, any]> {
  let result = new Array<[K, any]>()
  map.forEach((v, k) => {
    if (v instanceof Map) result.push([k, mapToJSONObject(v)])
    else if (v instanceof Set) result.push([k, setToJSONObject(v)])
    else result.push([k, v])
  })

  return result
}

export function setToJSONObject<T extends Freezable>(set: Set<T>): Array<any> {
  let result = Array<any>()
  set.forEach(item => {
    if (item instanceof Map) result.push(mapToJSONObject(item))
    else if (item instanceof Set) result.push(setToJSONObject(item))
    else result.push(item)
  })

  return result
}
