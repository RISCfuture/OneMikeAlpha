import {identity} from "lodash-es";

const bsearch = function<Value, Index>(array: Value[], key: Index, valueFunction: (v: Value) => Index = identity, {inexact = false}: {inexact: boolean}) {
  let low = 0, high = array.length - 1
  while (low <= high) {
    const mid = Math.floor(low + ((high - low)/2))
    const midValue = valueFunction(array[mid])
    if (midValue < key) low = mid + 1
    else if (midValue > key) high = mid - 1
    else return array[mid]
  }

  // key not found
  if (inexact) return array[low]
  else return null
}

export {bsearch}
