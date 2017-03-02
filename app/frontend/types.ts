import * as moment from 'moment'

interface IAirport {
  name: string
  identifier: string
  lid?: string
  icao?: string
  city: string
  state_code?: string
  country_code: string
  timezone: string
  lat: number
  lon: number
  elevation: number
}

export type Airport = Readonly<IAirport>

interface Style {
  thumbnail_url: string
}

interface BlankImage {
  blank: true
}

interface ActualImage {
  blank: false
  filename: string
  byte_size: number
  content_type: string
  styles: Style[]
}

type IImage = BlankImage | ActualImage
export type Image = Readonly<IImage>

interface Limitation {
  from?: string
  to?: string
  type: 'caution' | 'warning'
  plot_only: boolean
}

interface AircraftData {
  tacview_type: string
  systems: {
    [name: string]: string[]
  }
  limitations: {
    [parameter: string]: Limitation[]
  }
}

interface IContinuousChart {
  chart: string
  parameters: string[]
  i18n: string[]
  units: string
  referenceLines?: string
  series?: {
    [parameter: string]: string
  }
  unitLabel?: string,
  duration?: moment.unitOfTime.DurationConstructor
}

export type ContinuousChart = Readonly<IContinuousChart>

interface IDiscreteChart {
  parameter: string
  i18n?: string
  i18n_values?: string[],
  units?: string,
  unitLabel?: string
}

export type DiscreteChart = Readonly<IDiscreteChart>

interface IContinuousChartGroup {
  group: string
  charts: ContinuousChart[]
}

export type ContinuousChartGroup = Readonly<IContinuousChartGroup>

interface IDiscreteChartGroup {
  group: string
  parameters: DiscreteChart[]
}

export type DiscreteChartGroup = Readonly<IDiscreteChartGroup>

interface EquipmentData {
  importers: string[]
  estimated_values: string[]
  charts: {
    continuous: ContinuousChartGroup[]
    discrete: DiscreteChartGroup[]
  }
  tacview_properties: {
    [property: string]: string[] | string
  }
}

interface ICompositeData extends AircraftData, EquipmentData {}
export type CompositeData = Readonly<ICompositeData>

export interface Aircraft {
  id: string
  display_name: string
  name?: string
  registration: string

  composite_data: CompositeData

  permission?: {
    level: PermissionLevel
  }

  permissions?: {
    [email: string]: PermissionLevel
  }
}

interface IFlight {
  recording_start_time: string
  recording_end_time: string
  departure_time?: string
  arrival_time?: string
  takeoff_time?: string
  landing_time?: string

  duration?: number
  distance: number
  distance_flown: number

  id: string
  sort_key: number
  share_token: string

  origin?: Airport
  destination?: Airport
}

export type Flight = Readonly<IFlight>

export enum PermissionLevel {
  View = 'view',
  Upload = 'upload',
  Admin = 'admin'
}

export enum UploadState {
  Pending = 'pending',
  Processing = 'processing',
  Finished = 'finished',
  Failed = 'failed'
}

interface UploadFile {
  filename: string
  byte_size: number
}

export interface Upload {
  state: UploadState
  created_at: string
  files: UploadFile[]
  error?: string
}
