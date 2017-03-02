active_nav_system = ->(row) do
  case row[:crsselect]
    when '0'
      {type: 'fms'}
    when '1'
      {type: 'nav1'}
    when '2'
      {type: 'nav2'}
  end
end
active_nav_radio = ->(row) do
  case row[:crsselect]
    when '0'
      nil
    when '1'
      {type: 'nav1'}
    when '2'
      {type: 'nav2'}
  end
end

Importer::File::AvidyneR9::COLUMNS = {
    activewptid:           {
        class:     Telemetry::NavigationSystem,
        key:       {type: 'fms'},
        parameter: :active_waypoint
    },
    adahrsused:            [
        {
            class:     Telemetry::InstrumentSet,
            key:       ->(_row) { {type: this_ifd} },
            parameter: :adahrs
        },
        {
            class:     Telemetry::InstrumentSet,
            key:       ->(_row) { {type: this_ifd} },
            parameter: :pitot_static_system
        }
    ],
    adcseq:                nil,
    adcstatus:             nil,
    ahrsseq:               nil,
    ahrsstartupmode:       nil,
    ahrsstatusbits:        nil,
    altbug:                {
        class:     Telemetry::InstrumentSet,
        key:       ->(_row) { {type: this_ifd} },
        parameter: :altitude_bug,
        unit:      'ft'
    },
    altimetersetting:      {
        class:        Telemetry::InstrumentSet,
        key:          ->(_row) { {type: this_ifd} },
        parameter:    :altimeter_setting,
        unit:         'inHg',
        null_if_zero: true
    },
    autopilotmode:         :autopilot_mode,
    bodypitchrate:         {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_adahrs },
        parameter: :pitch_rate,
        unit:      'deg/s'
    },
    bodyrollrate:          {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_adahrs },
        parameter: :roll_rate,
        unit:      'deg/s'
    },
    bodyyawrate:           {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_adahrs },
        parameter: :yaw_rate,
        unit:      'deg/s'
    },
    coursedeviation:       {
        class:     Telemetry::NavigationSystem,
        key:       {type: 'fms'},
        parameter: :course_deviation,
        unit:      'deg'
    },
    crosstrackdeviation:   {
        class:     Telemetry::NavigationSystem,
        key:       {type: 'fms'},
        parameter: :lateral_deviation,
        unit:      'nmi'
    },
    crsselect:             {
        class:     Telemetry::InstrumentSet,
        key:       ->(_row) { {type: this_ifd} },
        parameter: :cdi_source
    },
    date:                  nil,
    deicevac:              {
        class:     Telemetry::AntiIceSystem,
        key:       {type: 'boots'},
        parameter: :vacuum,
        unit:      'inHg'
    },
    desiredtrack:          {
        class:     Telemetry::NavigationSystem,
        key:       {type: 'fms'},
        parameter: :desired_track,
        unit:      'deg'
    },
    dfc100alttarget:       {
        parameter: :autopilot_altitude_target,
        unit:      'ft'
    },
    dfc100failflags:       nil,
    dfc100latactive:       :autopilot_lateral_active_mode,
    dfc100latarmed:        :autopilot_lateral_armed_mode,
    dfc100statusflags:     nil,
    dfc100vertactive:      :autopilot_vertical_active_mode,
    dfc100vertarmed:       :autopilot_vertical_armed_mode,
    displaymode:           nil,
    distancetoactivewpt:   {
        class:     Telemetry::NavigationSystem,
        key:       {type: 'fms'},
        parameter: :distance_to_waypoint,
        unit:      'nmi'
    },
    eng1alt1current:       {
        class:     Telemetry::ElectricalSystem,
        key:       {type: 'alt1'},
        parameter: :current,
        unit:      'A'
    },
    eng1alt2current:       {
        class:     Telemetry::ElectricalSystem,
        key:       {type: 'alt2'},
        parameter: :current,
        unit:      'A'
    },
    eng1bat2current:       {
        class:     Telemetry::ElectricalSystem,
        key:       {type: 'bat2'},
        parameter: :current,
        unit:      'A'
    },
    eng1batcurrent:        {
        class:     Telemetry::ElectricalSystem,
        key:       {type: 'bat1'},
        parameter: :current,
        unit:      'A'
    },
    eng1bus2volts:         {
        class:     Telemetry::ElectricalSystem,
        key:       {type: 'emergency_bus'},
        parameter: :potential,
        unit:      'V'
    },
    'eng1cht[1]':          {
        class:     Telemetry::Engine::Cylinder,
        key:       {engine_number: 1, number: 1},
        parameter: :cylinder_head_temperature,
        unit:      'tempF'
    },
    'eng1cht[2]':          {
        class:     Telemetry::Engine::Cylinder,
        key:       {engine_number: 1, number: 2},
        parameter: :cylinder_head_temperature,
        unit:      'tempF'
    },
    'eng1cht[3]':          {
        class:     Telemetry::Engine::Cylinder,
        key:       {engine_number: 1, number: 3},
        parameter: :cylinder_head_temperature,
        unit:      'tempF'
    },
    'eng1cht[4]':          {
        class:     Telemetry::Engine::Cylinder,
        key:       {engine_number: 1, number: 4},
        parameter: :cylinder_head_temperature,
        unit:      'tempF'
    },
    'eng1cht[5]':          {
        class:     Telemetry::Engine::Cylinder,
        key:       {engine_number: 1, number: 5},
        parameter: :cylinder_head_temperature,
        unit:      'tempF'
    },
    'eng1cht[6]':          {
        class:     Telemetry::Engine::Cylinder,
        key:       {engine_number: 1, number: 6},
        parameter: :cylinder_head_temperature,
        unit:      'tempF'
    },
    eng1discreteinputs:    nil,
    eng1discreteoutputs:   nil,
    'eng1egt[1]':          {
        class:     Telemetry::Engine::Cylinder,
        key:       {engine_number: 1, number: 1},
        parameter: :exhaust_gas_temperature,
        unit:      'tempF'
    },
    'eng1egt[2]':          {
        class:     Telemetry::Engine::Cylinder,
        key:       {engine_number: 1, number: 2},
        parameter: :exhaust_gas_temperature,
        unit:      'tempF'
    },
    'eng1egt[3]':          {
        class:     Telemetry::Engine::Cylinder,
        key:       {engine_number: 1, number: 3},
        parameter: :exhaust_gas_temperature,
        unit:      'tempF'
    },
    'eng1egt[4]':          {
        class:     Telemetry::Engine::Cylinder,
        key:       {engine_number: 1, number: 4},
        parameter: :exhaust_gas_temperature,
        unit:      'tempF'
    },
    'eng1egt[5]':          {
        class:     Telemetry::Engine::Cylinder,
        key:       {engine_number: 1, number: 5},
        parameter: :exhaust_gas_temperature,
        unit:      'tempF'
    },
    'eng1egt[6]':          {
        class:     Telemetry::Engine::Cylinder,
        key:       {engine_number: 1, number: 6},
        parameter: :exhaust_gas_temperature,
        unit:      'tempF'
    },
    eng1manifoldpressure:  {
        class:     Telemetry::Engine,
        key:       {number: 1},
        parameter: :manifold_pressure,
        unit:      'inHg'
    },
    eng1mbus1volts:        {
        class:     Telemetry::ElectricalSystem,
        key:       {type: 'main_bus'},
        parameter: :potential,
        unit:      'V'
    },
    eng1mbus2volts:        {
        class:     Telemetry::ElectricalSystem,
        key:       {type: 'main_bus2'},
        parameter: :potential,
        unit:      'V'
    },
    eng1oilpressure:       {
        class:     Telemetry::Engine,
        key:       {number: 1},
        parameter: :oil_pressure,
        unit:      'psi'
    },
    eng1oiltemperature:    {
        class:     Telemetry::Engine,
        key:       {number: 1},
        parameter: :oil_temperature,
        unit:      'tempF'
    },
    eng1percentpwr:        {
        class:     Telemetry::Engine,
        key:       {number: 1},
        parameter: :percent_power
    },
    eng1rpm:               {
        class:     Telemetry::Engine::Propeller,
        key:       {engine_number: 1, number: 1},
        parameter: :rotational_velocity,
        unit:      'rpm'
    },
    eng1tit:               {
        class:     Telemetry::Engine,
        key:       {number: 1},
        parameter: :turbine_inlet_temperature,
        unit:      'tempF'
    },
    eng1bus1volts:         {
        class:     Telemetry::ElectricalSystem,
        key:       {type: 'main_bus'},
        parameter: :potential,
        unit:      'V'
    },
    eng1bus3volts:         {
        class:        Telemetry::ElectricalSystem,
        key:          {type: 'main_bus2'},
        parameter:    :potential,
        unit:         'V',
        null_if_zero: true
    },
    flaps:                 {
        class:     Telemetry::ControlSurface,
        key:       {type: 'flaps'},
        parameter: :position,
        unit:      'deg'
    },
    flightdirectoronoff:   {
        class:     Telemetry::InstrumentSet,
        key:       ->(_row) { {type: this_ifd} },
        parameter: :flight_director_active
    },
    flightdirectorpitch:   {
        class:     Telemetry::InstrumentSet,
        key:       ->(_row) { {type: this_ifd} },
        parameter: :flight_director_pitch,
        unit:      'deg'
    },
    flightdirectorroll:    {
        class:     Telemetry::InstrumentSet,
        key:       ->(_row) { {type: this_ifd} },
        parameter: :flight_director_roll,
        unit:      'deg'
    },
    fltaatc:               nil,
    fltartc:               nil,
    fltartcdist:           nil,
    fltastatus:            nil,
    fltaterrdist:          nil,
    fltavspd:              nil,
    fmscourse:             {
        class:     Telemetry::NavigationSystem,
        key:       {type: 'fms'},
        parameter: :course,
        unit:      'deg'
    },
    fueleconomy:           {
        parameter: :fuel_totalizer_economy,
        unit:      'nmi/gal'
    },
    fuelflow:              {
        class:     Telemetry::Engine,
        key:       {number: 1},
        parameter: :fuel_flow,
        unit:      'gal/hr'
    },
    fuelremaining:         {
        parameter: :fuel_totalizer_remaining,
        unit:      'gal'
    },
    fueltimeremaining:     {
        parameter: :fuel_totalizer_time_remaining,
        unit:      'min'
    },
    fuelused:              {
        parameter: :fuel_totalizer_used,
        unit:      'gal'
    },
    glideslopedeviation:   {
        class:     Telemetry::NavigationSystem,
        key:       active_nav_system,
        parameter: :vertical_deviation_factor
    },
    gpsaglheight:          {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_gps },
        parameter: :height_agl,
        unit:      'm'
    },
    gpsmslaltitude:        {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_gps },
        parameter: :altitude,
        unit:      'm'
    },
    gpsaltitude:           {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_gps },
        parameter: :altitude,
        unit:      'm'
    },
    gpshorizprotlimit:     nil,
    gpslatitude:           {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_gps },
        parameter: :latitude
    },
    gpslongitude:          {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_gps },
        parameter: :longitude
    },
    gpsselect:             {
        class:     Telemetry::InstrumentSet,
        key:       ->(_row) { {type: this_ifd} },
        parameter: :gps
    },
    gpsstate:              {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_gps },
        parameter: :state
    },
    gpsvertprotlimit:      nil,
    groundspeed:           {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_gps },
        parameter: :ground_speed,
        unit:      'kt'
    },
    groundtrack:           {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_gps },
        parameter: :magnetic_track,
        unit:      'deg'
    },
    hdgbug:                {
        class:     Telemetry::InstrumentSet,
        key:       ->(_row) { {type: this_ifd} },
        parameter: :heading_bug,
        unit:      'deg'
    },
    heading:               {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_adahrs },
        parameter: :magnetic_heading,
        unit:      'deg'
    },
    headingrate:           {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_adahrs },
        parameter: :heading_rate,
        unit:      'deg/s'
    },
    hfom:                  {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_gps },
        parameter: :horizontal_figure_of_merit,
        unit:      'm'
    },
    hplsbas:               {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_gps },
        parameter: :horizontal_protection_level,
        unit:      'm'
    },
    indicatedairspeed:     {
        class:     Telemetry::PitotStaticSystem,
        key:       ->(_row) { active_adahrs },
        parameter: :indicated_airspeed,
        unit:      'kt'
    },
    irustatus:             nil,
    itt:                   {
        class:     Telemetry::Engine,
        key:       {number: 1},
        parameter: :interstage_turbine_temperature,
        unit:      'tempC'
    },
    lfuelqty:              {
        class:     Telemetry::FuelTank,
        key:       {type: 'left'},
        parameter: :quantity,
        unit:      'gal'
    },
    lateralacc:            {
        parameter: :acceleration_lateral,
        unit:      'gee'
    },
    localizerdeviation:    {
        class:     Telemetry::NavigationSystem,
        key:       active_nav_system,
        parameter: :lateral_deviation_factor
    },
    longacc:               {
        parameter: :acceleration_longitudinal,
        unit:      'gee'
    },
    magstatus:             nil,
    magvar:                {
        parameter: :magnetic_variation,
        unit:      'deg'
    },
    mpustatus:             nil,
    navaidbrg:             {
        class:     Telemetry::NavigationSystem,
        key:       active_nav_system,
        parameter: :bearing,
        unit:      'deg'
    },
    navfreq:               {
        class:     Telemetry::Radio,
        key:       active_nav_radio,
        parameter: :active_frequency,
        unit:      'kHz'
    },
    navigationmode:        {
        class:     Telemetry::NavigationSystem,
        key:       {type: 'fms'},
        parameter: :mode
    },
    navtype:               {
        class:     Telemetry::NavigationSystem,
        key:       active_nav_system,
        parameter: :mode
    },
    ng:                    {
        class:     Telemetry::Engine::Spool,
        key:       {engine_number: 1, number: 1},
        parameter: :n
    },
    normacc:               {
        parameter: :acceleration_normal,
        unit:      'gee'
    },
    np:                    {
        class:     Telemetry::Engine::Propeller,
        key:       {engine_number: 1, number: 1},
        parameter: :rotational_velocity,
        unit:      'rpm'
    },
    obs:                   {
        class:     Telemetry::InstrumentSet,
        key:       ->(_row) { {type: this_ifd} },
        parameter: :obs,
        unit:      'deg'
    },
    outsideairtemperature: {
        class:     Telemetry::PitotStaticSystem,
        key:       ->(_row) { active_adahrs },
        parameter: :total_air_temperature,
        unit:      'tempC'
    },
    pitch:                 {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_adahrs },
        parameter: :pitch,
        unit:      'deg'
    },
    pressurealtitude:      {
        class:     Telemetry::PitotStaticSystem,
        key:       ->(_row) { active_adahrs },
        parameter: :pressure_altitude,
        unit:      'ft'
    },
    rfuelqty:              {
        class:     Telemetry::FuelTank,
        key:       {type: 'right'},
        parameter: :quantity,
        unit:      'gal'
    },
    roll:                  {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_adahrs },
        parameter: :roll,
        unit:      'deg'
    },
    ruddertrim:            {
        class:     Telemetry::ControlSurface,
        key:       {type: 'rudder'},
        parameter: :trim,
        unit:      'deg'
    },
    systime:               nil,
    time:                  nil,
    torque:                {
        class:     Telemetry::Engine,
        key:       {number: 1},
        parameter: :torque,
        unit:      'ft-lb'
    },
    trueairspeed:          {
        class:     Telemetry::PitotStaticSystem,
        key:       ->(_row) { active_adahrs },
        parameter: :true_airspeed,
        unit:      'kts'
    },
    verticaldeviation:     {
        class:     Telemetry::NavigationSystem,
        key:       {type: 'fms'},
        parameter: :vertical_deviation,
        unit:      'ft'
    },
    verticalspeed:         {
        class:     Telemetry::PitotStaticSystem,
        key:       ->(_row) { active_adahrs },
        parameter: :vertical_speed,
        unit:      'ft/min'
    },
    vfom:                  {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_gps },
        parameter: :vertical_figure_of_merit,
        unit:      'm'
    },
    vplsbas:               {
        class:     Telemetry::PositionSensor,
        key:       ->(_row) { active_gps },
        parameter: :vertical_protection_level,
        unit:      'm'
    },
    vsibug:                {
        class:     Telemetry::InstrumentSet,
        key:       ->(_row) { {type: this_ifd} },
        parameter: :vertical_speed_bug,
        unit:      'ft/min'
    }
}.freeze
