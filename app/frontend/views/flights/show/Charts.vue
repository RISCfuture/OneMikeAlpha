<template>
  <div>
    <chart v-for="chart in charts"
           :aircraft="aircraft"
           :flight="flight"
           :chart="chart"
           :key="chart"
           :markers="markerPlotLines"
           @remove="removeChart"></chart>

    <div class="add-chart">
      <div>
        {{$t('views.flights.show.charts.addChart')}}
        <select name="add-chart" ref="addChart" @change="addChart()">
          <option></option>
          <optgroup v-for="group in chartData"
                    :label="chartGroupName(group)"
                    :key="group.group"
                    v-if="showGroup(group)">
            <option v-if="!chartShown(chart)"
                    v-for="chart in group.charts"
                    :value="chart.chart"
                    :key="chart.chart">{{chartName(chart)}}
            </option>
          </optgroup>
        </select>
      </div>

      <div>
        {{$t('views.flights.show.charts.showMarkers')}}
        <select name="set-marker" ref="setMarker" @change="setMarker()">
          <option></option>
          <optgroup v-for="group in markerGroups"
                    :label="markerGroupName(group)"
                    :key="group.group">
            <option v-for="marker in group.parameters"
                    :value="marker.parameter"
                    :selected="currentMarker === marker.parameter"
                    :key="marker.parameter">{{markerName(marker)}}
            </option>
          </optgroup>
        </select>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
  import * as moment from 'moment'
  import * as Highcharts from 'highcharts'
  import Component, {mixins} from 'vue-class-component'
  import {Action, Getter} from 'vuex-class'
  import {Prop, Watch} from 'vue-property-decorator'

  import {unitI18nKey, unitsAmerican, UnitSystem} from 'data/units' //TODO allow user to choose units
  import CurrentRoute from 'mixins/CurrentRoute'
  import Chart from './Chart.vue'
  import {
    Aircraft,
    ContinuousChart,
    ContinuousChartGroup,
    DiscreteChart,
    DiscreteChartGroup,
    Flight
  } from 'types'
  import {Datapoint, TimeRange} from 'store'
  import {formatValue, t} from 'utilities/i18n'
  import {clone, get, isArray, isNull, isString, pull, reject} from "lodash-es";

  @Component({
    components: {Chart}
  })
  export default class Charts extends mixins(CurrentRoute) {
    @Prop({type: Object, required: true}) aircraft: Aircraft
    @Prop({type: Object, required: true}) flight: Flight

    @Getter visibleRouteRegion?: TimeRange
    @Getter boundariesForChart: (parameter: string, min: number, max: number) => Datapoint<string | number | null>[]
    @Getter boundariesLoading: boolean
    @Getter boundariesError?: Error

    get chartData(): ContinuousChartGroup[] {
      if (!this.aircraft) return []
      return this.aircraft.composite_data.charts.continuous
    }

    get charts(): string[] {
      if (!this.queryValue('charts')) return []
      return this.queryValue('charts').split(',')
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

    @Action loadBoundariesForChartIfNeeded: (params: {aircraft: Aircraft, token: string, parameter: string, min: number, max: number}) => Promise<void>

    addChart() {
      const value = this.$refs.addChart.value
      const charts = this.charts.concat(value).join(',')
      this.$router.push({query: Object.assign({}, this.$route.query, {charts: charts})})
      this.$refs.addChart.value = ''
    }

    removeChart(chart: string) {
      if (!this.queryValue('charts')) return
      let charts = clone(this.charts)
      pull(charts, chart)
      this.$router.push({query: Object.assign({}, this.$route.query, {charts: charts.join(',')})})
    }

    chartGroupName(group: ContinuousChartGroup): string { return t(`charts.continuous.groups.${group.group}`) }
    chartName(chart: ContinuousChart): string { return t(`charts.continuous.names.${chart.chart}`) }
    chartShown(chart: ContinuousChart): boolean { return this.charts.includes(chart.chart) }

    showGroup(group: ContinuousChartGroup): boolean {
      return reject(group.charts,
          chart => this.charts.includes(chart.chart)).length > 0
    }

    get markerGroups(): DiscreteChartGroup[] {
      if (!this.aircraft) return []
      return this.aircraft.composite_data.charts.discrete
    }

    get markerPlotLines(): Highcharts.XAxisPlotLinesOptions[] {
      return this.markerValues.map(([time, value]) => {
        return {
          color: '#07101340', //TODO from config.scss
          label: {text: this.markerTextValue(value)},
          value: time,
          width: 1,
          zIndex: 4
        }
      })
    }

    private get markerValues(): Datapoint<string | number | null>[] {
      if (!this.currentMarker) return []
      return this.boundariesForChart(
          this.currentMarker,
          this.minZoomedTime,
          this.maxZoomedTime
      )
    }

    get currentMarker(): string | null { return this.queryValue('marker') }

    private get markerInfo(): DiscreteChart | null {
      if (!this.markerGroups) return null

      for (let g = 0; g !== this.markerGroups.length; g++) {
        const group = this.markerGroups[g]
        for (let p = 0; p !== group.parameters.length; p++) {
          const param = group.parameters[p]
          if (param.parameter === this.currentMarker)
            return param
        }
      }

      return null
    }

    setMarker() {
      const value = this.$refs.setMarker.value
      this.$router.push({query: Object.assign({}, this.$route.query, {marker: value})})
    }

    markerGroupName(group: DiscreteChartGroup): string { return t(`charts.discrete.groups.${group.group}`) }
    markerName(marker: DiscreteChart): string { return t(`charts.discrete.names.${marker.i18n}`) }

    private markerTextValue(value: string | number | null): string {
      if (!this.markerInfo) return value.toString()
      if (isNull(value)) return t('charts.discrete.values.null')
      if (isString(value)) return value

      if (this.markerInfo.units) {
        let num = Number(value)
        const unit = UnitSystem.base.makeUnit(num, this.markerInfo.units)
        const converted = unitsAmerican.convertToSystem(unit, this.markerInfo.units)

        let format: string
        if (this.markerInfo.unitLabel)
          format = t(`charts.units.${this.markerInfo.unitLabel}.format`)
        else format = t(`charts.units.${unitI18nKey(converted)}.format`)
        return formatValue(converted.scalar, format)
      } else if (this.markerInfo.i18n_values) {
        const i18nValue = get(this.markerInfo, ['i18n_values', value])
        if (i18nValue)
          return t(`charts.discrete.values.${i18nValue}`, {default: value})
        else return formatValue(value)
      } else return formatValue(value)
    }

    private loadMarkers() {
      if (!this.currentMarker) return
      if (this.boundariesLoading) return

      this.loadBoundariesForChartIfNeeded({
        aircraft: this.aircraft,
        token: this.flight.id,
        parameter: this.currentMarker,
        min: this.minZoomedTime,
        max: this.maxZoomedTime
      })
    }

    private queryValue(name: string): string | null {
      if (!this.$route.query[name]) return null
      if (isArray(this.$route.query[name])) return this.$route.query[name][0]
      return this.$route.query[name] as string
    }

    @Watch('aircraft')
    onCurrentAircraftChanged(after: Aircraft, before: Aircraft) {
      if (before === after) return
      this.loadMarkers()
    }

    @Watch('flight')
    onCurrentFlightChanged(after: Flight, before: Flight) {
      if (before === after) return
      this.loadMarkers()
    }

    @Watch('currentMarker')
    onCurrentMarkerChanged(after: string, before: string) {
      if (before === after) return
      this.loadMarkers()
    }

    @Watch('visibleRouteRegion')
    onVisibleRouteRegionChanged(after: TimeRange, before: TimeRange) {
      if (before === after) return
      this.loadMarkers()
    }

    created() {
      this.loadMarkers()
    }
  }
</script>

<style lang="scss">
  @import "../../../stylesheets/config.scss";

  .add-chart {
    padding: 20px;
    border: 2px solid $platinum;
    border-radius: 5px;
    display: flex;
    flex-flow: row wrap;
  }

  .add-chart > div {
    flex: 1 1 auto;
    padding: 0 5px;
  }

  .add-chart > div:last-child {
    text-align: right;
    flex: 0 0 auto;
  }

  .sortable-chart {
    margin-bottom: 20px;
  }

  .highcharts-plot-line-label {
    fill: #777;
  }
</style>
