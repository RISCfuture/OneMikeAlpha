<template>
  <div class="sortable-chart">
    <div>
      <highcharts :options="chartOptions" ref="chart" />
    </div>
    <a href="#" @click.prevent="remove()"></a>
  </div>
</template>

<script lang="ts">
  import Vue from 'vue'
  import * as Qty from 'js-quantities'
  import * as moment from 'moment'
  import * as Highcharts from 'highcharts'
  import Component from 'vue-class-component'
  import {Prop, Watch} from 'vue-property-decorator'
  import {Action, Getter} from 'vuex-class'

  import chartConstants from 'data/charts/constants'
  import chartColors from 'data/charts/colors'
  import {unitI18nKey, unitsAmerican} from 'data/units' //TODO allow user to choose units
  import {ScrubberBus} from 'config/scrubberBus'
  import {Aircraft, ContinuousChart, Flight} from 'types'
  import {TimeRange} from 'store'
  import {TelemetryDatapoint} from 'store/modules/telemetry'
  import {formatValue, t} from 'utilities/i18n'
  import {ChartEvent, highlightPoint} from 'config/highcharts-extensions/scrubber'
  import {
    assign,
    flatMap,
    get,
    has,
    isNull,
    isString, isUndefined,
    mapValues,
    merge,
    reject, uniq
  } from "lodash-es";

  declare module 'highcharts' {
    interface Series {
      searchPoint(e: Highcharts.PointerCoordinatesObject, compareX: boolean): Highcharts.Point
    }
  }

  @Component
  export default class Chart extends Vue {
    @Prop({type: Object, required: true}) aircraft: Aircraft
    @Prop({type: Object, required: true}) flight: Flight
    @Prop({type: String, required: true}) chart: string
    @Prop({type: Array, required: true}) markers: Highcharts.XAxisPlotLinesOptions[]

    @Getter visibleRouteRegion?: TimeRange
    @Getter datasetsForChart: (parameters: string[], min: number, max: number) => TelemetryDatapoint[][]
    @Getter telemetryLoading: boolean
    @Getter telemetryError?: Error
    @Getter minParameterValue: (parameters: string[]) => number | null
    @Getter maxParameterValue: (parameters: string[]) => number | null

    private get batchUnitConverter(): (val: number) => number { return unitsAmerican.batchConverterToSystem(this.info.units) }

    private get datasets(): [number, number | null][][] {
      const datasets = this.datasetsForChart(
          this.info.parameters,
          this.minZoomedTime,
          this.maxZoomedTime)

      return datasets.map(dataset => {
        return dataset.map(([time, value]) => {
          let convertedValue: number | null
          if (isString(value)) convertedValue = Number(value) // should never happen because continuous charts are made only of numeric values
          else if (isNull(value)) return [time, null]
          else convertedValue = value
          return [time, this.batchUnitConverter(convertedValue)]
        })
      })
    }

    private get dataMin(): number | null {
      if (!this.info) return null
      const parameters = reject(this.info.parameters, c => {
        return get(chartConstants.series, [c, 'noEffectOnExtremes'], false)
      }) as string[] // not sure why this is necessary

      const minValue = this.minParameterValue(parameters)
      if (isNull(minValue)) return null
      return this.batchUnitConverter(minValue)
    }
    private get dataMax(): number | null {
      if (!this.info) return null
      const parameters = reject(this.info.parameters, c => {
        return get(chartConstants.series, [c, 'noEffectOnExtremes'], false)
      }) as string[] // not sure why this is necessary

      const maxValue = this.maxParameterValue(parameters)
      if (isNull(maxValue)) return null
      return this.batchUnitConverter(maxValue)
    }

    private get minZoomedTime(): number | null {
      if (!this.flight) return null
      if (this.visibleRouteRegion) return moment(this.visibleRouteRegion[0]).unix()*1000
      return moment(this.flight.departure_time).unix()*1000
    }
    private get maxZoomedTime(): number | null {
      if (!this.flight) return null
      if (this.visibleRouteRegion) return moment(this.visibleRouteRegion[1]).unix()*1000
      return moment(this.flight.arrival_time).unix()*1000
    }

    private get info(): ContinuousChart | null {
      if (!this.aircraft) return null

      const groups = this.aircraft.composite_data.charts.continuous
      const charts = flatMap(groups, group => group.charts)
      return charts.find(chart => (chart.chart === this.chart))
    }

    private get title(): string { return t(`charts.continuous.names.${this.chart}`) }
    private get label(): string {
      if (has(this.info, 'unitLabel'))
        return t(`charts.units.${this.info.unitLabel}.label`)
      else if (has(this.info, 'units'))
        return t(`charts.units.${this.unitI18nKey}.label`)
      else
        return ""
    }
    private get format(): string {
      if (has(this.info, 'unitLabel'))
        return t(`charts.units.${this.info.unitLabel}.format`)
      else if (has(this.info, 'units'))
        return t(`charts.units.${this.unitI18nKey}.format`)
      else
        return ""
    }

    private get unitI18nKey(): string {
      return unitI18nKey(Qty(1, unitsAmerican[this.info.units]))
    }

    private get chartData(): Highcharts.SeriesLineOptions[] {
      if (!this.info) return []
      return this.info.parameters.reduce((data, parameter, index) => {
        let config = {
          type: 'line',
          name: this.seriesName(parameter, index),
          id: parameter,
          data: this.datasets[index],
          dashStyle: (this.isEstimated(parameter) ? 'shortDash' : 'solid')
        }
        if (has(this.info, ['series', parameter]))
          merge(config, chartConstants.series[this.info.series[parameter]])
        data.push(config)
        return data
      }, [])
    }

    get chartOptions(): Highcharts.Options {
      const self = this
      return {
        chart: {
          animation: false,
          marginLeft: 100 //TODO is this wide enough
        },
        title: {text: this.title},
        series: this.chartData,
        xAxis: {
          type: 'datetime',
          crosshair: true,
          dateTimeLabelFormats: this.axisDateTimeLabelFormats,
          plotLines: this.markers,
          min: this.minZoomedTime,
          max: this.maxZoomedTime
        },
        yAxis: {
          title: {text: this.label},
          labels: {
            formatter() { return formatValue(this.value, self.format, self.info.duration) }
          },
          plotLines: this.referenceLines?.map(line => Object.assign({zIndex: 3}, line)),
          plotBands: this.plotBands,
          min: this.dataMin,
          max: this.dataMax
        },
        legend: ((this.info && this.info.parameters && this.info.parameters.length === 1) ? {enabled: false} : {
          layout: 'horizontal',
          align: 'left',
          verticalAlign: 'top',
          floating: false,
          borderWidth: 0
        }),
        plotOptions: {
          spline: {
            marker: {enabled: false}
          },
          series: {
            animation: false
          }
        },
        tooltip: {
          shared: true,
          pointFormatter() {
            if (get(self.info, ['series', this.series.options.id, 'showInLegend']) === false)
              return null

            const formatted = formatValue(this.y, self.format, self.info.duration)
            // @ts-ignore: color is a private property on Series but we need it
            const color = this.series.color
            return t('charts.options.pointFormatter', {color: color, name: this.series.name, value: formatted})
          },
          dateTimeLabelFormats: this.tooltipDateTimeLabelFormats,
          shadow: false,
          style: {
            backgroundColor: '#aaaaaa33',
            cursor: 'default',
            fontSize: '12px',
            pointerEvents: 'none',
            whiteSpace: 'nowrap'
          }
        }
      }
    }

    private get tooltipDateTimeLabelFormats(): Highcharts.Dictionary<string> {
      return this.$t('charts.options.dateTimeLabelFormats', {returnObjects: true}) as unknown as Highcharts.Dictionary<string>
    }

    private get axisDateTimeLabelFormats(): Highcharts.AxisDateTimeLabelFormatsOptions {
      return mapValues(this.tooltipDateTimeLabelFormats, (format) => {
        return {main: format}
      })
    }

    private get referenceLines(): Highcharts.XAxisPlotLinesOptions[] | null {
      if (!this.info || !this.info.referenceLines) return null
      return chartConstants.referenceLines[this.info.referenceLines].map(referenceLine => {
        return merge({}, referenceLine, {
          value: this.convertUnits(referenceLine.value).scalar,
        })
      })
    }

    private get plotBands(): Highcharts.XAxisPlotBandsOptions[] {
      if (!this.aircraft || !this.info) return []

      let aircraftPlotBands = this.aircraft.composite_data.limitations
      const normalizedParameters: string[] = uniq(this.info.parameters.map(p => this.normalizeParameter(p)))
      return normalizedParameters.reduce((array, parameter) => {
        if (!aircraftPlotBands[parameter]) return array

        aircraftPlotBands[parameter].forEach(plotBand => {
          array.push({
            from: plotBand.from ? this.convertUnits(Qty(plotBand.from)).scalar : Number.MIN_SAFE_INTEGER,
            to: plotBand.to ? this.convertUnits(Qty(plotBand.to)).scalar : Number.MAX_SAFE_INTEGER,
            color: chartColors.bands[plotBand.type]
          })
        })
        return array
      }, [])
    }

    @Action setHoverTimestamp: (params: {timestamp: number}) => void
    @Action loadTelemetryForChartIfNeeded: (params: {aircraft: Aircraft, token: string, parameters: string[], min: number, max: number}) => Promise<void>

    private convertUnits(value: Qty): Qty { return unitsAmerican.convertToSystem(value, this.info.units) }

    private normalizeParameter(param: string): string { return param.replace(/\[\w+]/g, '[any]') }

    private loadTelemetry() {
      if (!this.info) return
      // if (this.telemetryLoading) return

      this.loadTelemetryForChartIfNeeded({
        aircraft: this.aircraft,
        token: this.flight.share_token,
        parameters: this.info.parameters,
        min: this.minZoomedTime,
        max: this.maxZoomedTime
      })
    }

    remove() {
      this.$emit('remove', this.chart)
    }

    private redoSeries() {
      if (!this.$refs.chart.chart) return
      if (this.telemetryLoading) return

      this.chartData.forEach(series => {
        let existingSeries = this.$refs.chart.chart.series.find(s => s.options.id === series.id)
        if (existingSeries)
          existingSeries.setData(<Array<[number, number | null]>>series.data, false)
        else
          this.$refs.chart.chart.addSeries(series, false)
      })

      this.$refs.chart.chart.redraw()
    }

    private broadcastScrub(e: Highcharts.PointerEventObject) {
      const chart = get(this.$refs, 'chart.chart')
      if (!chart) return
      if (!chart.series[0]) return

      ScrubberBus.$emit('scrub', e)
    }

    private slaveScrubber(event: Highcharts.PointerEventObject) {
      const chart: Highcharts.Chart = get(this.$refs, 'chart.chart')
      if (!chart) return
      if (!chart.series[0]) return

      const normalizedEvent = chart.pointer.normalize(event)
      const point = chart.series[0].searchPoint(event, true)
      if (isUndefined(point)) return
      highlightPoint(point, normalizedEvent)
    }

    private highlightPointOnPlanview(e: PointerEvent | TouchEvent) {
      const thisChart = this.$refs.chart.chart
      if (!thisChart.series[0]) return

      const event = thisChart.pointer.normalize(e)
      const currentPoint = thisChart.series[0].searchPoint(event, true)
      if (!currentPoint) return

      this.setHoverTimestamp({timestamp: currentPoint.x})
    }

    private isEstimated(param: string): boolean {
      const estimated = get(this.aircraft.composite_data, 'estimated_values', [])
      return estimated.includes(this.normalizeParameter(param))
    }

    private seriesName(param: string, i18nIndex: number): string {
      const name = t(`charts.parameters.${this.info.i18n[i18nIndex]}`)
      if (this.isEstimated(param))
        return t('charts.estimatedParameter', {param: name})
      else
        return name
    }

    @Watch('chart')
    onChartChanged(after: string, before: string) {
      if (before === after) return
      this.loadTelemetry()
    }

    @Watch('aircraft')
    onCurrentAircraftChanged(after: Aircraft, before: Aircraft) {
      if (before === after) return
      this.loadTelemetry()
    }

    @Watch('flight')
    onCurrentFlightChanged(after: Flight, before: Flight) {
      if (before === after) return
      this.loadTelemetry()
    }

    @Watch('telemetryLoading')
    onTelemetryLoadingChanged(after: boolean, before: boolean) {
      if (before === after) return
      this.redoSeries()
    }

    @Watch('visibleRouteRegion')
    onVisibleRouteRegionChanged(after: TimeRange, before: TimeRange) {
      if (before === after) return
      this.$refs.chart.chart.xAxis[0].setExtremes(this.minZoomedTime, this.maxZoomedTime, true)
      this.loadTelemetry()
    }

    created() {
      this.loadTelemetry()
    }

    mounted() {
      this.$el.addEventListener('mousemove', this.broadcastScrub, {passive: true})
      this.$el.addEventListener('touchmove', this.broadcastScrub, {passive: true})
      this.$el.addEventListener('touchstart', this.broadcastScrub, {passive: true})

      this.$el.addEventListener('mousemove', this.highlightPointOnPlanview, {passive: true})
      this.$el.addEventListener('touchmove', this.highlightPointOnPlanview, {passive: true})
      this.$el.addEventListener('touchstart', this.highlightPointOnPlanview, {passive: true})

      ScrubberBus.$on('scrub', this.slaveScrubber)
    }

    beforeDestroy() {
      this.$el.removeEventListener('mousemove', this.broadcastScrub)
      this.$el.removeEventListener('touchmove', this.broadcastScrub)
      this.$el.removeEventListener('touchstart', this.broadcastScrub)

      this.$el.removeEventListener('mousemove', this.highlightPointOnPlanview)
      this.$el.removeEventListener('touchmove', this.highlightPointOnPlanview)
      this.$el.removeEventListener('touchstart', this.highlightPointOnPlanview)
    }
  }
</script>

<style lang="scss">
  .sortable-chart {
    display: flex;
    flex-flow: row nowrap;
    align-items: center;

    > div {
      flex: 1 1 auto;
    }

    > a {
      flex: 0 0 auto;
      width: 18px;
      height: 24px;
      background-image: url('../../../images/trash/inactive.svg');

      &:hover {
        background-image: url('../../../images/trash/hover.svg');
      }

      &:active {
        background-image: url('../../../images/trash/active.svg');
      }
    }
  }
</style>
