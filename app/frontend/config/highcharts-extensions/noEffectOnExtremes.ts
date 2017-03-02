import { ExtremesObject, Series, wrap } from "highcharts";

wrap(Series.prototype, 'getExtremes', function(original) {
  const extremes: ExtremesObject = original.apply(this, Array.prototype.slice.call(arguments, 1))
  if (this.userOptions.noEffectOnExtremes) {
    extremes.dataMin = undefined
    extremes.dataMax = undefined
  }
  return extremes
})
