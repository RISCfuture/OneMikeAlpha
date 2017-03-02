import * as Highcharts from 'highcharts'

Highcharts.wrap(Highcharts.Series.prototype, 'getExtremes', function(original) {
  original.apply(this, Array.prototype.slice.call(arguments, 1))
  if (this.userOptions.noEffectOnExtremes) {
    this.dataMin = undefined
    this.dataMax = undefined
  }
})
