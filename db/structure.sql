SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data';


--
-- Name: file_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS file_fdw WITH SCHEMA public;


--
-- Name: EXTENSION file_fdw; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION file_fdw IS 'foreign-data wrapper for flat file access';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: file_import; Type: SERVER; Schema: -; Owner: -
--

CREATE SERVER file_import FOREIGN DATA WRAPPER file_fdw;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    service_name character varying NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: aircraft; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aircraft (
    id bigint NOT NULL,
    slug character varying NOT NULL,
    registration character varying(10) NOT NULL,
    name character varying(20),
    aircraft_data character varying NOT NULL,
    equipment_data text
);


--
-- Name: aircraft_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.aircraft_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aircraft_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.aircraft_id_seq OWNED BY public.aircraft.id;


--
-- Name: airports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.airports (
    id bigint NOT NULL,
    fadds_site_number character varying(11),
    icao_number integer,
    lid character varying(4),
    icao character varying(4),
    iata character varying(3),
    name character varying(100) NOT NULL,
    location public.geography(PointZ,4326) NOT NULL,
    city character varying(40),
    state_code character varying(2),
    country_code character varying(2) NOT NULL,
    timezone character varying(32)
);


--
-- Name: airports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.airports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: airports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.airports_id_seq OWNED BY public.airports.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: flights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flights (
    id bigint NOT NULL,
    aircraft_id bigint NOT NULL,
    origin_id bigint,
    destination_id bigint,
    slug character varying NOT NULL,
    share_token character varying NOT NULL,
    recording_start_time timestamp without time zone,
    recording_end_time timestamp without time zone,
    departure_time timestamp without time zone,
    arrival_time timestamp without time zone,
    takeoff_time timestamp without time zone,
    landing_time timestamp without time zone,
    significant boolean,
    track public.geography(LineStringZ,4326)
);


--
-- Name: flights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flights_id_seq OWNED BY public.flights.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendly_id_slugs (
    id bigint NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendly_id_slugs_id_seq OWNED BY public.friendly_id_slugs.id;


--
-- Name: jwt_blacklists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jwt_blacklists (
    jti character varying NOT NULL
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    user_id bigint NOT NULL,
    aircraft_id bigint NOT NULL,
    level smallint DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: runways; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.runways (
    id bigint NOT NULL,
    fadds_site_number character varying(11),
    fadds_name character varying(7),
    icao_number integer,
    icao_airport_number integer,
    base boolean NOT NULL,
    name character varying(10) NOT NULL,
    location public.geography(PointZ,4326) NOT NULL,
    length double precision,
    width double precision,
    landing_distance_available double precision
);


--
-- Name: runways_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.runways_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: runways_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.runways_id_seq OWNED BY public.runways.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: telemetry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    acceleration_lateral double precision,
    acceleration_longitudinal double precision,
    acceleration_normal double precision,
    magnetic_variation double precision,
    grid_convergence double precision,
    fuel_totalizer_used double precision,
    fuel_totalizer_remaining double precision,
    fuel_totalizer_economy double precision,
    fuel_totalizer_used_weight double precision,
    fuel_totalizer_remaining_weight double precision,
    fuel_totalizer_economy_weight double precision,
    fuel_totalizer_time_remaining double precision,
    autopilot_active boolean,
    autopilot_mode smallint,
    autopilot_lateral_active_mode smallint,
    autopilot_lateral_armed_mode smallint,
    autopilot_vertical_active_mode smallint,
    autopilot_vertical_armed_mode smallint,
    autopilot_altitude_target double precision,
    autothrottle_active_mode smallint,
    autothrottle_armed_mode smallint,
    master_warning boolean,
    master_caution boolean,
    fire_warning boolean,
    drift_angle double precision,
    wind_direction double precision,
    wind_speed double precision,
    mass double precision,
    center_of_gravity double precision,
    percent_mac double precision
);


--
-- Name: telemetry_anti_ice_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_anti_ice_systems (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    active boolean,
    mode smallint,
    current double precision,
    fluid_quantity double precision,
    fluid_flow_rate double precision,
    vacuum double precision
);


--
-- Name: telemetry_bleed_air_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_bleed_air_systems (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    active boolean,
    pressure double precision,
    temperature double precision,
    valve_position double precision
);


--
-- Name: telemetry_control_surfaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_control_surfaces (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    "position" double precision,
    "trim" double precision,
    position_factor double precision,
    trim_factor double precision
);


--
-- Name: telemetry_displays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_displays (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    active boolean,
    format smallint
);


--
-- Name: telemetry_electrical_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_electrical_systems (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    active boolean,
    current double precision,
    potential double precision,
    frequency double precision
);


--
-- Name: telemetry_engine_cylinders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_engine_cylinders (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    engine_number smallint NOT NULL,
    number smallint NOT NULL,
    cylinder_head_temperature double precision,
    exhaust_gas_temperature double precision
);


--
-- Name: telemetry_engine_propellers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_engine_propellers (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    engine_number smallint NOT NULL,
    number smallint NOT NULL,
    rotational_velocity double precision
);


--
-- Name: telemetry_engine_spools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_engine_spools (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    engine_number smallint NOT NULL,
    number smallint NOT NULL,
    n double precision,
    rotational_velocity double precision
);


--
-- Name: telemetry_engines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_engines (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    number smallint NOT NULL,
    fuel_flow double precision,
    fuel_pressure double precision,
    vibration double precision,
    thrust_lever_position double precision,
    reverser_position double precision,
    reverser_lever_stowed boolean,
    throttle_position double precision,
    mixture_lever_position double precision,
    propeller_lever_position double precision,
    magneto_position smallint,
    carburetor_heat_lever_position double precision,
    cowl_flap_lever_position double precision,
    altitude_throttle_position double precision,
    condition_lever_position double precision,
    beta_position double precision,
    ignition_mode smallint,
    autothrottle_active boolean,
    fuel_source smallint,
    reverser_opened boolean,
    torque double precision,
    torque_factor double precision,
    autofeather_armed boolean,
    manifold_pressure double precision,
    thrust double precision,
    percent_thrust double precision,
    power double precision,
    percent_power double precision,
    engine_pressure_ratio double precision,
    exhaust_gas_temperature double precision,
    interstage_turbine_temperature double precision,
    turbine_inlet_temperature double precision,
    oil_pressure double precision,
    oil_temperature double precision
);


--
-- Name: telemetry_flight_controls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_flight_controls (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    set smallint NOT NULL,
    type smallint NOT NULL,
    "position" double precision,
    shaker boolean,
    pusher boolean
);


--
-- Name: telemetry_fuel_tanks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_fuel_tanks (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    quantity double precision,
    quantity_weight double precision,
    temperature double precision
);


--
-- Name: telemetry_hydraulic_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_hydraulic_systems (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    pressure double precision,
    temperature double precision,
    fluid_quantity double precision,
    fluid_quantity_percent double precision
);


--
-- Name: telemetry_ice_detection_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_ice_detection_systems (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    ice_detected boolean
);


--
-- Name: telemetry_instrument_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_instrument_sets (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    flight_director smallint,
    ins smallint,
    gps smallint,
    adahrs smallint,
    fms smallint,
    nav_radio smallint,
    adf smallint,
    pitot_static_system smallint,
    cdi_source smallint,
    obs double precision,
    course double precision,
    altitude_bug double precision,
    decision_height double precision,
    indicated_airspeed_bug double precision,
    mach_bug double precision,
    vertical_speed_bug double precision,
    flight_path_angle_bug double precision,
    heading_bug double precision,
    track_bug double precision,
    indicated_altitude double precision,
    altimeter_setting double precision,
    flight_director_active boolean,
    flight_director_pitch double precision,
    flight_director_roll double precision
);


--
-- Name: telemetry_landing_gear_tires; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_landing_gear_tires (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    truck_type smallint NOT NULL,
    number smallint NOT NULL,
    brake_temperature double precision,
    air_pressure double precision
);


--
-- Name: telemetry_landing_gear_trucks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_landing_gear_trucks (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    door_state smallint,
    weight_on_wheels boolean
);


--
-- Name: telemetry_marker_beacons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_marker_beacons (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    "outer" boolean,
    middle boolean,
    "inner" boolean
);


--
-- Name: telemetry_navigation_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_navigation_systems (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    active boolean,
    mode smallint,
    desired_track double precision,
    course double precision,
    bearing double precision,
    course_deviation double precision,
    lateral_deviation double precision,
    vertical_deviation double precision,
    lateral_deviation_factor double precision,
    vertical_deviation_factor double precision,
    active_waypoint character varying(64),
    distance_to_waypoint double precision,
    radio_type smallint
);


--
-- Name: telemetry_packs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_packs (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    number smallint NOT NULL,
    active boolean,
    air_pressure double precision,
    air_temperature double precision
);


--
-- Name: telemetry_pitot_static_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_pitot_static_systems (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    static_air_temperature double precision,
    total_air_temperature double precision,
    temperature_deviation double precision,
    air_pressure double precision,
    air_density double precision,
    pressure_altitude double precision,
    density_altitude double precision,
    indicated_airspeed double precision,
    calibrated_airspeed double precision,
    true_airspeed double precision,
    speed_of_sound double precision,
    mach double precision,
    vertical_speed double precision,
    angle_of_attack double precision,
    angle_of_sideslip double precision
);


--
-- Name: telemetry_pneumatic_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_pneumatic_systems (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    pressure double precision
);


--
-- Name: telemetry_position_sensors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_position_sensors (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    state smallint,
    roll double precision,
    pitch double precision,
    true_heading double precision,
    magnetic_heading double precision,
    grid_heading double precision,
    true_track double precision,
    magnetic_track double precision,
    grid_track double precision,
    latitude double precision,
    longitude double precision,
    altitude double precision,
    ground_elevation double precision,
    height_agl double precision,
    pitch_rate double precision,
    roll_rate double precision,
    yaw_rate double precision,
    heading_rate double precision,
    ground_speed double precision,
    vertical_speed double precision,
    climb_gradient double precision,
    climb_angle double precision,
    horizontal_figure_of_merit double precision,
    vertical_figure_of_merit double precision,
    horizontal_protection_level double precision,
    vertical_protection_level double precision
);


--
-- Name: telemetry_positions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_positions (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    "position" public.geography(PointZ,4326)
);


--
-- Name: telemetry_pressurization_system_valves; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_pressurization_system_valves (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    system_type smallint NOT NULL,
    number smallint NOT NULL,
    "position" double precision
);


--
-- Name: telemetry_pressurization_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_pressurization_systems (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    mode smallint,
    differential_pressure double precision,
    cabin_altitude double precision,
    cabin_rate double precision,
    target_altitude double precision
);


--
-- Name: telemetry_radio_altimeters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_radio_altimeters (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    state smallint,
    altitude double precision,
    alert_altitude double precision
);


--
-- Name: telemetry_radios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_radios (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    active boolean,
    monitoring boolean,
    monitoring_standby boolean,
    transmitting boolean,
    receiving boolean,
    squelched boolean,
    beat_frequency_oscillation boolean,
    ident boolean,
    single_sideband boolean,
    active_frequency integer,
    standby_frequency integer,
    volume double precision,
    squelch double precision
);


--
-- Name: telemetry_rotors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_rotors (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    number smallint NOT NULL,
    rotational_velocity double precision,
    blade_angle double precision
);


--
-- Name: telemetry_traffic_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_traffic_systems (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    mode smallint,
    traffic_advisory boolean,
    resolution_advisory boolean,
    horizontal_resolution_advisory smallint,
    vertical_resolution_advisory smallint
);


--
-- Name: telemetry_transponders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry_transponders (
    aircraft_id bigint NOT NULL,
    "time" timestamp without time zone NOT NULL,
    number smallint NOT NULL,
    mode smallint,
    mode_3a_code smallint,
    mode_s_code integer,
    flight_id character varying(16),
    replying boolean
);


--
-- Name: timezones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timezones (
    id bigint NOT NULL,
    name character varying(32) NOT NULL,
    boundaries public.geography(MultiPolygon,4326) NOT NULL
);


--
-- Name: timezones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.timezones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timezones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.timezones_id_seq OWNED BY public.timezones.id;


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploads (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    aircraft_id bigint NOT NULL,
    state smallint DEFAULT 0 NOT NULL,
    error character varying,
    workflow_uuid character varying(36),
    earliest_time timestamp without time zone,
    latest_time timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.uploads_id_seq OWNED BY public.uploads.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying NOT NULL,
    encrypted_password character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: workflow_dependencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_dependencies (
    step_id bigint NOT NULL,
    dependency_id bigint NOT NULL
);


--
-- Name: workflow_steps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_steps (
    id bigint NOT NULL,
    workflow_uuid character varying(36) NOT NULL,
    workflow_class_name character varying NOT NULL,
    step_name character varying,
    arguments text,
    processing boolean DEFAULT false NOT NULL
);


--
-- Name: workflow_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workflow_steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workflow_steps_id_seq OWNED BY public.workflow_steps.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: aircraft id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aircraft ALTER COLUMN id SET DEFAULT nextval('public.aircraft_id_seq'::regclass);


--
-- Name: airports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airports ALTER COLUMN id SET DEFAULT nextval('public.airports_id_seq'::regclass);


--
-- Name: flights id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flights ALTER COLUMN id SET DEFAULT nextval('public.flights_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('public.friendly_id_slugs_id_seq'::regclass);


--
-- Name: runways id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runways ALTER COLUMN id SET DEFAULT nextval('public.runways_id_seq'::regclass);


--
-- Name: timezones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timezones ALTER COLUMN id SET DEFAULT nextval('public.timezones_id_seq'::regclass);


--
-- Name: uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads ALTER COLUMN id SET DEFAULT nextval('public.uploads_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: workflow_steps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_steps ALTER COLUMN id SET DEFAULT nextval('public.workflow_steps_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: aircraft aircraft_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aircraft
    ADD CONSTRAINT aircraft_pkey PRIMARY KEY (id);


--
-- Name: airports airports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airports
    ADD CONSTRAINT airports_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: flights flights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flights
    ADD CONSTRAINT flights_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (user_id, aircraft_id);


--
-- Name: runways runways_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runways
    ADD CONSTRAINT runways_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: telemetry_anti_ice_systems telemetry_anti_ice_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_anti_ice_systems
    ADD CONSTRAINT telemetry_anti_ice_systems_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_bleed_air_systems telemetry_bleed_air_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_bleed_air_systems
    ADD CONSTRAINT telemetry_bleed_air_systems_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_control_surfaces telemetry_control_surfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_control_surfaces
    ADD CONSTRAINT telemetry_control_surfaces_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_displays telemetry_displays_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_displays
    ADD CONSTRAINT telemetry_displays_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_electrical_systems telemetry_electrical_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_electrical_systems
    ADD CONSTRAINT telemetry_electrical_systems_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_engine_cylinders telemetry_engine_cylinders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_engine_cylinders
    ADD CONSTRAINT telemetry_engine_cylinders_pkey PRIMARY KEY (aircraft_id, "time", engine_number, number);


--
-- Name: telemetry_engine_propellers telemetry_engine_propellers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_engine_propellers
    ADD CONSTRAINT telemetry_engine_propellers_pkey PRIMARY KEY (aircraft_id, "time", engine_number, number);


--
-- Name: telemetry_engine_spools telemetry_engine_spools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_engine_spools
    ADD CONSTRAINT telemetry_engine_spools_pkey PRIMARY KEY (aircraft_id, "time", engine_number, number);


--
-- Name: telemetry_engines telemetry_engines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_engines
    ADD CONSTRAINT telemetry_engines_pkey PRIMARY KEY (aircraft_id, "time", number);


--
-- Name: telemetry_flight_controls telemetry_flight_controls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_flight_controls
    ADD CONSTRAINT telemetry_flight_controls_pkey PRIMARY KEY (aircraft_id, "time", set, type);


--
-- Name: telemetry_fuel_tanks telemetry_fuel_tanks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_fuel_tanks
    ADD CONSTRAINT telemetry_fuel_tanks_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_hydraulic_systems telemetry_hydraulic_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_hydraulic_systems
    ADD CONSTRAINT telemetry_hydraulic_systems_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_ice_detection_systems telemetry_ice_detection_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_ice_detection_systems
    ADD CONSTRAINT telemetry_ice_detection_systems_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_instrument_sets telemetry_instrument_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_instrument_sets
    ADD CONSTRAINT telemetry_instrument_sets_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_landing_gear_tires telemetry_landing_gear_tires_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_landing_gear_tires
    ADD CONSTRAINT telemetry_landing_gear_tires_pkey PRIMARY KEY (aircraft_id, "time", truck_type, number);


--
-- Name: telemetry_landing_gear_trucks telemetry_landing_gear_trucks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_landing_gear_trucks
    ADD CONSTRAINT telemetry_landing_gear_trucks_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_marker_beacons telemetry_marker_beacons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_marker_beacons
    ADD CONSTRAINT telemetry_marker_beacons_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_navigation_systems telemetry_navigation_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_navigation_systems
    ADD CONSTRAINT telemetry_navigation_systems_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_packs telemetry_packs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_packs
    ADD CONSTRAINT telemetry_packs_pkey PRIMARY KEY (aircraft_id, "time", number);


--
-- Name: telemetry_pitot_static_systems telemetry_pitot_static_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_pitot_static_systems
    ADD CONSTRAINT telemetry_pitot_static_systems_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry telemetry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry
    ADD CONSTRAINT telemetry_pkey PRIMARY KEY (aircraft_id, "time");


--
-- Name: telemetry_pneumatic_systems telemetry_pneumatic_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_pneumatic_systems
    ADD CONSTRAINT telemetry_pneumatic_systems_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_position_sensors telemetry_position_sensors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_position_sensors
    ADD CONSTRAINT telemetry_position_sensors_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_positions telemetry_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_positions
    ADD CONSTRAINT telemetry_positions_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_pressurization_system_valves telemetry_pressurization_system_valves_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_pressurization_system_valves
    ADD CONSTRAINT telemetry_pressurization_system_valves_pkey PRIMARY KEY (aircraft_id, "time", system_type, number);


--
-- Name: telemetry_pressurization_systems telemetry_pressurization_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_pressurization_systems
    ADD CONSTRAINT telemetry_pressurization_systems_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_radio_altimeters telemetry_radio_altimeters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_radio_altimeters
    ADD CONSTRAINT telemetry_radio_altimeters_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_radios telemetry_radios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_radios
    ADD CONSTRAINT telemetry_radios_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_rotors telemetry_rotors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_rotors
    ADD CONSTRAINT telemetry_rotors_pkey PRIMARY KEY (aircraft_id, "time", number);


--
-- Name: telemetry_traffic_systems telemetry_traffic_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_traffic_systems
    ADD CONSTRAINT telemetry_traffic_systems_pkey PRIMARY KEY (aircraft_id, "time", type);


--
-- Name: telemetry_transponders telemetry_transponders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry_transponders
    ADD CONSTRAINT telemetry_transponders_pkey PRIMARY KEY (aircraft_id, "time", number);


--
-- Name: timezones timezones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timezones
    ADD CONSTRAINT timezones_pkey PRIMARY KEY (id);


--
-- Name: uploads uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: workflow_steps workflow_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_steps
    ADD CONSTRAINT workflow_steps_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_aircraft_on_registration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_aircraft_on_registration ON public.aircraft USING btree (registration);


--
-- Name: index_airports_on_fadds_site_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_airports_on_fadds_site_number ON public.airports USING btree (fadds_site_number);


--
-- Name: index_airports_on_iata; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_airports_on_iata ON public.airports USING btree (iata);


--
-- Name: index_airports_on_icao; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_airports_on_icao ON public.airports USING btree (icao);


--
-- Name: index_airports_on_icao_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_airports_on_icao_number ON public.airports USING btree (icao_number);


--
-- Name: index_airports_on_lid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_airports_on_lid ON public.airports USING btree (lid);


--
-- Name: index_airports_on_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_airports_on_location ON public.airports USING gist (location);


--
-- Name: index_flights_on_aircraft_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flights_on_aircraft_id ON public.flights USING btree (aircraft_id);


--
-- Name: index_flights_on_destination_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flights_on_destination_id ON public.flights USING btree (destination_id);


--
-- Name: index_flights_on_origin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flights_on_origin_id ON public.flights USING btree (origin_id);


--
-- Name: index_flights_on_track; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flights_on_track ON public.flights USING gist (track);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON public.friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON public.friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_type_and_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type_and_sluggable_id ON public.friendly_id_slugs USING btree (sluggable_type, sluggable_id);


--
-- Name: index_permissions_on_aircraft_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_aircraft_id ON public.permissions USING btree (aircraft_id);


--
-- Name: index_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_user_id ON public.permissions USING btree (user_id);


--
-- Name: index_runways_on_fadds_site_number_and_fadds_name_and_base; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_runways_on_fadds_site_number_and_fadds_name_and_base ON public.runways USING btree (fadds_site_number, fadds_name, base);


--
-- Name: index_runways_on_icao_number_and_base; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_runways_on_icao_number_and_base ON public.runways USING btree (icao_number, base);


--
-- Name: index_runways_on_landing_distance_available; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runways_on_landing_distance_available ON public.runways USING btree (landing_distance_available);


--
-- Name: index_runways_on_length; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runways_on_length ON public.runways USING btree (length);


--
-- Name: index_runways_on_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runways_on_location ON public.runways USING gist (location);


--
-- Name: index_runways_on_width; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runways_on_width ON public.runways USING btree (width);


--
-- Name: index_timezones_on_boundaries; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timezones_on_boundaries ON public.timezones USING gist (boundaries);


--
-- Name: index_timezones_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_timezones_on_name ON public.timezones USING btree (name);


--
-- Name: index_uploads_on_aircraft_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_aircraft_id ON public.uploads USING btree (aircraft_id);


--
-- Name: index_uploads_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_user_id ON public.uploads USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_workflow_dependencies_on_dependency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_dependencies_on_dependency_id ON public.workflow_dependencies USING btree (dependency_id);


--
-- Name: index_workflow_dependencies_on_step_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_dependencies_on_step_id ON public.workflow_dependencies USING btree (step_id);


--
-- Name: index_workflow_steps_on_workflow_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_steps_on_workflow_uuid ON public.workflow_steps USING btree (workflow_uuid);


--
-- Name: telemetry_anti_ice_systems_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_anti_ice_systems_time_idx ON public.telemetry_anti_ice_systems USING btree ("time" DESC);


--
-- Name: telemetry_bleed_air_systems_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_bleed_air_systems_time_idx ON public.telemetry_bleed_air_systems USING btree ("time" DESC);


--
-- Name: telemetry_control_surfaces_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_control_surfaces_time_idx ON public.telemetry_control_surfaces USING btree ("time" DESC);


--
-- Name: telemetry_displays_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_displays_time_idx ON public.telemetry_displays USING btree ("time" DESC);


--
-- Name: telemetry_electrical_systems_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_electrical_systems_time_idx ON public.telemetry_electrical_systems USING btree ("time" DESC);


--
-- Name: telemetry_engine_cylinders_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_engine_cylinders_time_idx ON public.telemetry_engine_cylinders USING btree ("time" DESC);


--
-- Name: telemetry_engine_propellers_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_engine_propellers_time_idx ON public.telemetry_engine_propellers USING btree ("time" DESC);


--
-- Name: telemetry_engine_spools_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_engine_spools_time_idx ON public.telemetry_engine_spools USING btree ("time" DESC);


--
-- Name: telemetry_engines_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_engines_time_idx ON public.telemetry_engines USING btree ("time" DESC);


--
-- Name: telemetry_flight_controls_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_flight_controls_time_idx ON public.telemetry_flight_controls USING btree ("time" DESC);


--
-- Name: telemetry_fuel_tanks_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_fuel_tanks_time_idx ON public.telemetry_fuel_tanks USING btree ("time" DESC);


--
-- Name: telemetry_hydraulic_systems_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_hydraulic_systems_time_idx ON public.telemetry_hydraulic_systems USING btree ("time" DESC);


--
-- Name: telemetry_ice_detection_systems_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_ice_detection_systems_time_idx ON public.telemetry_ice_detection_systems USING btree ("time" DESC);


--
-- Name: telemetry_instrument_sets_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_instrument_sets_time_idx ON public.telemetry_instrument_sets USING btree ("time" DESC);


--
-- Name: telemetry_landing_gear_tires_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_landing_gear_tires_time_idx ON public.telemetry_landing_gear_tires USING btree ("time" DESC);


--
-- Name: telemetry_landing_gear_trucks_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_landing_gear_trucks_time_idx ON public.telemetry_landing_gear_trucks USING btree ("time" DESC);


--
-- Name: telemetry_marker_beacons_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_marker_beacons_time_idx ON public.telemetry_marker_beacons USING btree ("time" DESC);


--
-- Name: telemetry_navigation_systems_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_navigation_systems_time_idx ON public.telemetry_navigation_systems USING btree ("time" DESC);


--
-- Name: telemetry_packs_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_packs_time_idx ON public.telemetry_packs USING btree ("time" DESC);


--
-- Name: telemetry_pitot_static_systems_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_pitot_static_systems_time_idx ON public.telemetry_pitot_static_systems USING btree ("time" DESC);


--
-- Name: telemetry_pneumatic_systems_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_pneumatic_systems_time_idx ON public.telemetry_pneumatic_systems USING btree ("time" DESC);


--
-- Name: telemetry_position_sensors_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_position_sensors_time_idx ON public.telemetry_position_sensors USING btree ("time" DESC);


--
-- Name: telemetry_positions_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_positions_time_idx ON public.telemetry_positions USING btree ("time" DESC);


--
-- Name: telemetry_pressurization_system_valves_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_pressurization_system_valves_time_idx ON public.telemetry_pressurization_system_valves USING btree ("time" DESC);


--
-- Name: telemetry_pressurization_systems_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_pressurization_systems_time_idx ON public.telemetry_pressurization_systems USING btree ("time" DESC);


--
-- Name: telemetry_radio_altimeters_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_radio_altimeters_time_idx ON public.telemetry_radio_altimeters USING btree ("time" DESC);


--
-- Name: telemetry_radios_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_radios_time_idx ON public.telemetry_radios USING btree ("time" DESC);


--
-- Name: telemetry_rotors_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_rotors_time_idx ON public.telemetry_rotors USING btree ("time" DESC);


--
-- Name: telemetry_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_time_idx ON public.telemetry USING btree ("time" DESC);


--
-- Name: telemetry_traffic_systems_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_traffic_systems_time_idx ON public.telemetry_traffic_systems USING btree ("time" DESC);


--
-- Name: telemetry_transponders_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_transponders_time_idx ON public.telemetry_transponders USING btree ("time" DESC);


--
-- Name: telemetry ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_anti_ice_systems ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_anti_ice_systems FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_bleed_air_systems ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_bleed_air_systems FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_control_surfaces ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_control_surfaces FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_displays ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_displays FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_electrical_systems ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_electrical_systems FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_engine_cylinders ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_engine_cylinders FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_engine_propellers ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_engine_propellers FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_engine_spools ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_engine_spools FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_engines ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_engines FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_flight_controls ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_flight_controls FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_fuel_tanks ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_fuel_tanks FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_hydraulic_systems ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_hydraulic_systems FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_ice_detection_systems ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_ice_detection_systems FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_instrument_sets ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_instrument_sets FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_landing_gear_tires ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_landing_gear_tires FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_landing_gear_trucks ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_landing_gear_trucks FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_marker_beacons ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_marker_beacons FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_navigation_systems ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_navigation_systems FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_packs ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_packs FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_pitot_static_systems ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_pitot_static_systems FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_pneumatic_systems ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_pneumatic_systems FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_position_sensors ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_position_sensors FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_positions ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_positions FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_pressurization_system_valves ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_pressurization_system_valves FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_pressurization_systems ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_pressurization_systems FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_radio_altimeters ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_radio_altimeters FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_radios ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_radios FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_rotors ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_rotors FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_traffic_systems ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_traffic_systems FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: telemetry_transponders ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.telemetry_transponders FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: flights fk_rails_06d41095ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flights
    ADD CONSTRAINT fk_rails_06d41095ce FOREIGN KEY (aircraft_id) REFERENCES public.aircraft(id) ON DELETE CASCADE;


--
-- Name: uploads fk_rails_15d41e668d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT fk_rails_15d41e668d FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: flights fk_rails_17532769c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flights
    ADD CONSTRAINT fk_rails_17532769c7 FOREIGN KEY (destination_id) REFERENCES public.airports(id) ON DELETE SET NULL;


--
-- Name: uploads fk_rails_268fed4123; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT fk_rails_268fed4123 FOREIGN KEY (aircraft_id) REFERENCES public.aircraft(id) ON DELETE CASCADE;


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: workflow_dependencies fk_rails_9adcef103a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_dependencies
    ADD CONSTRAINT fk_rails_9adcef103a FOREIGN KEY (step_id) REFERENCES public.workflow_steps(id) ON DELETE RESTRICT;


--
-- Name: flights fk_rails_b1cc9638ed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flights
    ADD CONSTRAINT fk_rails_b1cc9638ed FOREIGN KEY (origin_id) REFERENCES public.airports(id) ON DELETE SET NULL;


--
-- Name: workflow_dependencies fk_rails_c23a19eba9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_dependencies
    ADD CONSTRAINT fk_rails_c23a19eba9 FOREIGN KEY (dependency_id) REFERENCES public.workflow_steps(id) ON DELETE CASCADE;


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: permissions fk_rails_d9cfa3c257; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT fk_rails_d9cfa3c257 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: permissions fk_rails_fa8fb0ec39; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT fk_rails_fa8fb0ec39 FOREIGN KEY (aircraft_id) REFERENCES public.aircraft(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('1'),
('10'),
('11'),
('12'),
('13'),
('14'),
('15'),
('16'),
('17'),
('18'),
('19'),
('2'),
('20'),
('20190906202009'),
('20210608221246'),
('20210608221247'),
('21'),
('22'),
('23'),
('24'),
('25'),
('26'),
('27'),
('28'),
('29'),
('3'),
('30'),
('31'),
('32'),
('33'),
('34'),
('35'),
('36'),
('37'),
('38'),
('39'),
('4'),
('40'),
('41'),
('42'),
('43'),
('44'),
('45'),
('5'),
('6'),
('7'),
('8'),
('9');


