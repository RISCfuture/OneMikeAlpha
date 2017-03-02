<template>
  <div id="planview-container">
    <div id="planview"></div>
    <p id="map-styles">
      <span v-if="mapStyle === 'streets-v11'">{{$t('views.flights.show.planview.mapStyle.road')}}</span>
      <a v-else href="#" @click.prevent="setStyle('streets-v11')">{{$t('views.flights.show.planview.mapStyle.road')}}</a> |
      <span v-if="mapStyle === 'satellite-v9'">{{$t('views.flights.show.planview.mapStyle.satellite')}}</span>
      <a v-else href="#" @click.prevent="setStyle('satellite-v9')">{{$t('views.flights.show.planview.mapStyle.satellite')}}</a>
    </p>
    <p id="download">
      {{$t('views.flights.show.planview.downloadLink')}}
      <a :href="downloadKML" :download="exportFileName('kml')">KML</a> |
      <a :href="downloadGPX" :download="exportFileName('gpx')">GPX</a> |
      <a :href="downloadTacview" :download="exportFileName('acmi')">Tacview</a>
      <br />
    </p>
  </div>
</template>

<script lang="ts">
  import * as mapbox from 'mapbox-gl'
  import * as moment from 'moment'
  import Component, {mixins} from 'vue-class-component'
  import {Prop, Watch} from 'vue-property-decorator'
  import {Action, Getter} from 'vuex-class'

  import Secrets from 'config/secrets.js'
  import CurrentRoute from 'mixins/CurrentRoute'
  import {Aircraft, Flight} from 'types'
  import {Coordinate} from 'store/modules/route'
  import {get, last} from "lodash-es";

  @Component
  export default class Planview extends mixins(CurrentRoute) {
    map?: mapbox.Map = null
    mapDisplayed = false
    mapBoundsUpdateTimer?: number = null
    firstLoad = true
    mapStyle = 'streets-v11'
    routeRendered = false

    @Prop({type: Object, required: true}) aircraft: Aircraft
    @Prop({type: Object, required: true}) flight: Flight

    @Getter routeCoordinates: Coordinate[]
    @Getter coordinateForTime: (timestamp: number) => Coordinate | null
    @Getter hoverTimestamp?: number

    get downloadKML() { return `/flights/${this.flight.share_token}.kml` }
    get downloadGPX() { return `/flights/${this.flight.share_token}.gpx` }
    get downloadTacview() { return `/flights/${this.flight.share_token}.acmi` }

    @Action resetRouteTelemetry: () => void
    @Action loadRouteTelemetry: (params: {aircraftID: string, token: string, start: string, stop: string, force: boolean}) => Promise<boolean>
    @Action setMapBounds: (params: {bounds: mapbox.LngLatBounds}) => void

    private loadRoute() {
      if (!this.aircraft || !this.flight)
        this.resetRouteTelemetry()
      else
        this.loadRouteTelemetry({
          aircraftID: this.aircraft.id,
          token: this.flight.share_token,
          start: this.flight.departure_time,
          stop: this.flight.arrival_time,
          force: true
        })
    }

    private displayRoute() {
      if (!this.map) return
      this.renderWhenStyleLoaded()
      this.highlightInRoute()
    }

    private renderWhenStyleLoaded() {
      const render = () => {
        this.mapStyle = last(this.map.getStyle().sprite.split('/'))
        if (this.routeRendered) return

        window.setTimeout(()=> {
          this.removeLayers()
          if (this.routeCoordinates.length === 0) return

          this.addRouteLayer()
          this.addScrubberLayer()

          if (this.firstLoad) {
            this.firstLoad = false
            this.fitToBounds()
          }

          if (!this.mapDisplayed)
            this.map.addControl(new mapbox.NavigationControl())
          this.mapDisplayed = true

          this.routeRendered = true
        }, 200)
      }

      if (this.map.isStyleLoaded()) render()
      else {
        this.map.on('styledata', render)
        this.map.on('styledataloaded', render)
        this.map.on('style.load', render)
      }
    }

    private removeLayers() {
      if (this.map.getLayer('route')) this.map.removeLayer('route')
      if (this.map.getSource('route')) this.map.removeSource('route')
      if (this.map.getLayer('scrubber')) this.map.removeLayer('scrubber')
      if (this.map.getSource('scrubber')) this.map.removeSource('scrubber')
    }

    private addRouteLayer() {
      this.map.addSource('route', {
        type: 'geojson',
        data: {
          type: 'Feature',
          properties: {},
          geometry: {
            type: 'LineString',
            coordinates: this.routeCoordinates
          }
        }
      })
      this.map.addLayer({
        id: 'route',
        type: 'line',
        source: 'route',
        layout: {
          'line-join': 'round',
          'line-cap': 'round'
        },
        paint: {
          'line-color': '#d82d3e', //TODO constantize
          'line-width': 4
        }
      })
    }

    private addScrubberLayer() {
      this.map.addSource('scrubber', {
        type: 'geojson',
        data: {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [0, 0]
          },
          properties: null
        }
      })
      this.map.addLayer({
        id: 'scrubber',
        type: 'circle',
        source: 'scrubber',
        paint: {
          'circle-radius': 10,
          'circle-color': '#d82d3e' //TODO constantize
        }
      })
      this.map.setLayoutProperty('scrubber', 'visibility', 'none')
    }

    private fitToBounds() {
      const firstCoord: [number, number] = [this.routeCoordinates[0][0], this.routeCoordinates[0][1]]
      const bounds = this.routeCoordinates.reduce(
          (bounds, coord) => bounds.extend(new mapbox.LngLat(coord[0], coord[1])),
          new mapbox.LngLatBounds(firstCoord, firstCoord))
      this.map.fitBounds(bounds, {padding: 20})
    }

    private updateMapBounds() {
      if (this.mapBoundsUpdateTimer) window.clearTimeout(
          this.mapBoundsUpdateTimer)
      this.mapBoundsUpdateTimer = window.setTimeout(() => {
        this.setMapBounds({bounds: this.map.getBounds()})
      }, 500)
    }

    private highlightInRoute() {
      if (!this.map.getSource('scrubber')) return
      if (!this.map.getLayer('scrubber')) return

      if (this.hoverTimestamp) {
        const coordinates = this.coordinateForTime(this.hoverTimestamp)
        if (coordinates) {
          (<mapbox.GeoJSONSource>this.map.getSource('scrubber')).setData({
            type: 'Feature',
            geometry: {
              type: 'Point',
              coordinates: coordinates
            },
            properties: null
          })
          this.map.setLayoutProperty('scrubber', 'visibility', 'visible')
        }
        else
          this.map.setLayoutProperty('scrubber', 'visibility', 'none')
      } else
        this.map.setLayoutProperty('scrubber', 'visibility', 'none')
    }

    exportFileName(extension: string): string {
      const time = moment(this.flight.departure_time).format(<string>this.$t('date.dateOnlyFilename'))
      const unknownAirportName = this.$t('general.airport.unknown')

      let origin = get(this.flight, 'origin.identifier', unknownAirportName)
      if (origin === '---') origin = unknownAirportName
      let dest = get(this.flight, 'destination.identifier', unknownAirportName)
      if (dest=== '---') dest = unknownAirportName

      return `${time} ${origin}-${dest}.${extension}`
    }

    setStyle(style: string) {
      if (!this.map) return
      this.routeRendered = false
      this.map.setStyle(`mapbox://styles/mapbox/${style}`, {diff: false})
      this.displayRoute()
    }

    @Watch('routeCoordinates')
    onRouteCoordinatesChanged() { this.displayRoute() }

    @Watch('aircraft')
    onCurrentAircraftChanged(after: Aircraft, before: Aircraft) {
      if (before === after) return
      this.firstLoad = true
      this.routeRendered = false
      this.loadRoute()
    }

    @Watch('flight')
    onCurrentFlightChanged(after: Flight, before: Flight) {
      if (before === after) return
      this.firstLoad = true
      this.routeRendered = false
      this.loadRoute()
    }

    @Watch('hoverTimestamp')
    onHoverTimestampChanged() { this.highlightInRoute() }

    created() {
      this.loadRoute()
    }

    mounted() {
      // @ts-ignore: Claims accessToken is read-only
      mapbox.accessToken = Secrets.mapboxAccessToken
      this.map = new mapbox.Map({
        container: 'planview',
        style: 'mapbox://styles/mapbox/streets-v11'
      })

      this.map.on('moveend', this.updateMapBounds)
      this.map.on('zoomend', this.updateMapBounds)
      this.map.on('dragend', this.updateMapBounds)
    }
  }
</script>

<style lang="scss" scoped>
  #planview-container {
    margin-bottom: 10px;
    position: relative;
  }

  #planview {
    height: 400px;
  }

  p#download {
    font-size: 11px;
  }

  p#map-styles {
    position: absolute;
    left: 0;
    top: 0;
    margin: 0;
    padding: 5px;
    background-color: #fff;
    font-size: 11px;

    span {
      font-weight: bold;
    }
  }
</style>
