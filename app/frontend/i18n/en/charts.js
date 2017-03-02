export default {
  estimatedParameter: "{param} (est.)",
  continuous: {
    groups: {
      avionics: "Avionics",
      configuration: "Configuration",
      electrical: "Electrical",
      engine: "Engine",
      environment: "Environment",
      fuel: "Fuel",
      navigation: "Navigation",
      telemetry: "Telemetry"
    },
    names: {
      accelerations: "Accelerations",
      altimeter_setting: "Altimeter Setting",
      altitudes: "Altitudes + Bug",
      chts: "CHTs",
      course_deviation: "Course Deviation",
      courses: "FMS + OBS Courses",
      currents: "Alternators + Batteries Currents",
      deviations: "Localizer/Glideslope Deviation",
      egts: "EGTs",
      flight_director: "F/D Pitch/Roll",
      fuel_economy: "Fuel Economy",
      fuel_flow: "Fuel Flow",
      fuel_time: "Fuel Time Remaining",
      fuel_used: "Fuel Used + Remaining",
      gs: "G-Force/Load Factor",
      heading: "Heading + Bug",
      isa_dev: "ISA Temp Deviation",
      magnetic_variation: "Magnetic Variation",
      manifold_pressure: "Manifold Pressure",
      navaid_bearing: "Navaid Bearing",
      oat: "Outside Air Temperature",
      oil_pressure: "Oil Pressure",
      oil_temperature: "Oil Temperature",
      orientation: "Pitch + Roll",
      percent_power: "% Power",
      potentials: "Bus Voltages",
      rates: "Rates",
      rpm: "RPM",
      speeds: "Speeds",
      tracks: "Track + Desired Track",
      vertical_deviation: "Vertical Deviation",
      vertical_speed: "Vertical Speed + Bug",
      xtrack_deviation: "Cross-Track Deviation"
    },
  },
  discrete: {
    groups: {
      autopilot: "Autopilot",
      gps1: "GPS 1",
      gps2: "GPS 2",
      ifd1: "IFD 1",
      ifd2: "IFD 2",
      fms: "FMS",
      nav1: "NAV1 Radio",
      nav2: "NAV2 Radio"
    },
    names: {
      autopilot_lateral_active_mode: "Lateral Mode",
      autopilot_vertical_active_mode: "Vertical Mode",
      instrument_sets: {
        adahrs: "Active ADAHRS",
        cdi_source: "CDI Source",
        gps: "Active GPS",
        pitot_static_system: "Active Pitot/Static System"
      },
      navigation_systems: {
        fms: {
          active_waypoint: "Active Waypoint",
          mode: "NAV Mode"
        }
      },
      position_sensors: {
        gps: {
          state: "State"
        }
      },
      radios: {
        active_frequency: "Frequency"
      }
    },
    values: {
      autopilot_lateral_active_mode: {
        hdg: "HDG",
        loc: "LOC",
        loc_bc: "LOC BC",
        nav: "NAV",
        nav_appr: "NAV APPR",
        nav_intcpt: "NAV INTCPT",
        none: "off",
        roll: "ROLL",
        vor: "VOR",
        vor_appr: "VOR APPR"
      },
      autopilot_vertical_active_mode: {
        alt: "ALT",
        alt_gs: "ALT GS",
        gs: "GS",
        ias: "IAS",
        none: "off",
        pitch: "PITCH",
        vnav_alt: "VNAV ALT",
        vnav_vs: "VNAV VS",
        vs: "VS"
      },
      instrument_sets: {
        adahrs: {
          auto: "auto",
          adahrs1: "ADAHRS1",
          adahrs2: "ADAHRS2"
        },
        cdi_source: {
          fms: "FMS",
          nav1: "NAV1",
          nav2: "NAV2"
        },
        gps: {
          auto: "auto",
          gps1: "GPS1",
          gps2: "GPS2"
        },
      },
      navigation_systems: {
        fms: {
          mode: {
            approach: "approach",
            departure: "departure",
            enroute: "enroute",
            missed_approach: "missed approach",
            oceanic: "oceanic",
            terminal: "terminal"
          }
        },
        nav: {
          mode: {
            // null
            vor: "VOR",
            ils: "ILS"
          }
        }
      },
      null: "(none)",
      position_sensors: {
        gps: {
          state: {
            fault: "fault",
            fde: "FDE",
            initializing: "initializing",
            navigation: "navigation",
            sbas: "SBAS",
            searching: "searching",
            self_test: "self-test"
          }
        }
      }
    }
  },
  parameters: {
    acceleration_normal: "normal acceleration",
    acceleration_lateral: "lateral acceleration",
    acceleration_longitudinal: "longitudinal acceleration",
    engines: {
      cylinders: {
        '1': {
          cylinder_head_temperature: "CHT1",
          exhaust_gas_temperature: "EGT1"
        },
        '2': {
          cylinder_head_temperature: "CHT2",
          exhaust_gas_temperature: "EGT2"
        },
        '3': {
          cylinder_head_temperature: "CHT3",
          exhaust_gas_temperature: "EGT3"
        },
        '4': {
          cylinder_head_temperature: "CHT4",
          exhaust_gas_temperature: "EGT4"
        },
        '5': {
          cylinder_head_temperature: "CHT5",
          exhaust_gas_temperature: "EGT5"
        },
        '6': {
          cylinder_head_temperature: "CHT6",
          exhaust_gas_temperature: "EGT6"
        }
      },
      fuel_flow: "fuel flow",
      manifold_pressure: "manifold pressure",
      oil_pressure: "oil pressure",
      oil_temperature: "oil temperature",
      percent_power: "percent power",
      propellers: {
        rotational_velocity: "RPM"
      }
    },
    electrical_systems: {
      emergency_bus: {
        potential: "emergency bus voltage"
      },
      main_bus: {
        potential: "main bus voltage"
      }
    },
    fuel_totalizer_economy: "fuel economy (totalizer)",
    fuel_totalizer_used: "fuel used (totalizer)",
    fuel_totalizer_remaining: "fuel remaining (totalizer)",
    fuel_totalizer_time_remaining: "fuel time remaining (totalizer)",
    instrument_sets: {
      altimeter_setting: "altimeter setting",
      altitude_bug: "altitude bug",
      course: "FMS course",
      flight_director_pitch: "flight director pitch",
      flight_director_roll: "flight director roll",
      heading_bug: "heading bug",
      indicated_altitude: "indicated altitude",
      obs: "OBS",
      vertical_speed_bug: "V/S bug"
    },
    magnetic_variation: "magnetic variation",
    navigation_systems: {
      desired_track: "desired track",
      fms: {
        course_deviation: "FMS course deviation",
        lateral_deviation: "FMS cross-track deviation",
        vertical_deviation: "VNAV deviation"
      },
      nav1: {
        bearing: "NAV1 bearing",
        lateral_deviation_factor: "NAV1 horizontal deviation",
        vertical_deviation_factor: "NAV1 vertical deviation"
      },
      nav2: {
        bearing: "NAV2 bearing",
        lateral_deviation_factor: "NAV2 horizontal deviation",
        vertical_deviation_factor: "NAV2 vertical deviation"
      }
    },
    pitot_static_systems: {
      density_altitude: "density altitude",
      indicated_airspeed: "indicated airspeed",
      pressure_altitude: "pressure altitude",
      speed_of_sound: "speed of sound",
      static_air_temperature: "outside air temperature",
      temperature_deviation: "ISA temperature deviation",
      true_airspeed: "true airspeed",
      vertical_speed: "vertical speed"
    },
    position_sensors: {
      altitude: "altitude MSL",
      desired_track: "desired track",
      heading_rate: "heading rate",
      height_agl: "height AGL",
      ground_elevation: "ground elevation",
      ground_speed: "ground speed",
      magnetic_heading: "magnetic heading",
      magnetic_track: "magnetic track",
      pitch: "pitch",
      pitch_rate: "pitch rate",
      roll: "roll",
      roll_rate: "roll rate",
      yaw_rate: "yaw rate"
    }
  },
  units: {
    bar: {
      label: "bars",
      format: "{0.0} bar"
    },
    deg: {
      label: "degrees",
      format: "{0}°"
    },
    deg_per_s: {
      label: "degrees per second",
      format: "°/s"
    },
    degC: {
      label: "degrees Celsius",
      format: "{0} °C"
    },
    ft: {
      label: "feet",
      format: "{0,0}ʹ"
    },
    gal: {
      label: "gallons",
      format: "{0,0.0} gal"
    },
    gal_per_h: {
      label: "gallons per hour",
      format: "{0.0} gal/hr"
    },
    gee: {
      label: "g force",
      format: "{0.0} g"
    },
    hPa: {
      label: "hectopascals",
      format: "{0,0.0} hPa"
    },
    inHg: {
      label: "inches of mercury",
      format: "{0.00} inHg"
    },
    kg: {
      label: "kilograms",
      format: "{0,0.0} kg"
    },
    km_per_hr: {
      label: "kilometers per hour",
      format: "{0,0} kph"
    },
    km_per_L: {
      label: "kilometers per liter",
      format: "{0.0} km/L"
    },
    kt: {
      label: "knots",
      format: "{0} kts"
    },
    L_per_hr: {
      label: "liters per hour",
      format: "{0.0} L/hr"
    },
    lb: {
      label: "pounds",
      format: "{0,0} lbs"
    },
    m: {
      label: "meters",
      format: "{0} m"
    },
    MHz: {
      label: "megahertz",
      format: "{0.000} MHz"
    },
    min: {
      label: "minutes",
      format: "{0,0} min"
    },
    nmi: {
      label: "nautical miles",
      format: "{0,0.0} NM"
    },
    nmi_per_gal: {
      label: "nautical miles per gallon",
      format: "{0.0} NM/gal"
    },
    percent: {
      label: "percent",
      format: "{0}%"
    },
    psi: {
      label: "pounds per square inch",
      format: "{0.0} psi"
    },
    rpm: {
      label: "RPM",
      format: "{0,0} RPM"
    },
    tempC: {
      label: "degrees Celsius",
      format: "{0} °C"
    },
    tempF: {
      label: "degrees Fahrenheit",
      format: "{0} °F"
    },
    torr: {
      label: "torr",
      format: "{0.0} torr"
    },
    V: {
      label: "volts",
      format: "{0.0} V"
    }
  },
  options: {
    dateTimeLabelFormats: {
      millisecond: "%H%MZ+%S.%L",
      second: "%H%MZ+%S",
      minute: "%H%MZ",
      hour: "%H%MZ",
      day: "%b %e",
      week: "Week of %b %e, %Y",
      month: "%B %Y",
      year: "%Y"
    },
    pointFormatter: "<span style=\"color:{color}\">{name}</span>: <strong>{value}</strong><br />"
  }
}
