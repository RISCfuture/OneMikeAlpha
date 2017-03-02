import * as Highcharts from 'highcharts'
import * as Qty from 'js-quantities'

let series = new Map<string, Highcharts.PlotOptions>()
series['ground'] = {
  type: 'area',
  color: '#e2ccac',
  marker: {enabled: false},
  showInLegend: false,
  lineWidth: 0
}
series['speedOfSound'] = {
  color: '#b7999c',
  marker: {enabled: false},
  showInLegend: false,
  dashStyle: 'ShortDash',
  noEffectOnExtremes: true,
  enableMouseTracking: false
}

let referenceLines = new Map<string, Highcharts.XAxisPlotLinesOptions[]>()
referenceLines['standardRateTurns'] = [
  {
    value: Qty(1.5, 'deg/s'),
    color: '#aaa',
    dashStyle: 'shortDash',
    width: 1
  },
  {
    value: Qty(-1.5, 'deg/s'),
    color: '#aaa',
    dashStyle: 'shortDash',
    width: 1
  },
  {
    value: Qty(3, 'deg/s'),
    color: '#aaa',
    width: 1
  },
  {
    value: Qty(-3, 'deg/s'),
    color: '#aaa',
    width: 1
  }
]

referenceLines['significantAltitudes'] = [
  {
    value: Qty(12500, 'ft'),
    color: '#aaa',
    dashStyle: 'shortDash',
    width: 1
  },
  {
    value: Qty(18000, 'ft'),
    color: '#b7999c',
    dashStyle: 'shortDash',
    width: 1
  }
]

referenceLines['significantSpeeds'] = [
  {
    value: Qty(250, 'kt'),
    color: '#aaa',
    dashStyle: 'shortDash',
    width: 1
  }
]

referenceLines['fuelTimeReserves'] = [
  {
    value: Qty(45, 'min'),
    color: '#aaa',
    dashStyle: 'shortDash',
    width: 1
  },
  {
    value: Qty(30, 'min'),
    color: '#aaa',
    width: 1
  }
]

referenceLines['ISATemperatureDeviation'] = [
  {
    value: Qty(0, 'degC'),
    color: '#777',
    width: 1
  }
]

referenceLines['aerobaticLimits'] = [
  {
    value: Qty(30, 'deg'),
    color: '#b7999c',
    dashStyle: 'shortDash',
    width: 1
  },
  {
    value: Qty(60, 'deg'),
    color: '#b7999c',
    dashStyle: 'shortDash',
    width: 1
  },
  {
    value: Qty(-30, 'deg'),
    color: '#b7999c',
    dashStyle: 'shortDash',
    width: 1
  },
  {
    value: Qty(-60, 'deg'),
    color: '#b7999c',
    dashStyle: 'shortDash',
    width: 1
  }
]

export default {series, referenceLines}
