import * as Highcharts from 'highcharts'

export function highlightPoint(point: Highcharts.Point, event: Highcharts.PointerEventObject) {
  if (!point) return
  point.onMouseOver(event)
  point.series.chart.xAxis[0].drawCrosshair(event, this)
}

export type ChartEvent = Highcharts.PointerEventObject & {
  chartX: number
  chartY: number
}
