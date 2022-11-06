create table bookings.Fact_Flights (
passenger_id int not null,
actual_departure timestamp,
actual_arrival timestamp,
dt_departure int,
dt_arrival int,
aircraft_code char(3) not null,
departure_airport varchar(3) not null,
arrival_airport varchar(3) not null,
fare_conditions varchar(10),
 total_amount numeric(10,2)  NOT NULL ,
)



create table bookings.Dim_Calendar AS
WITH dates AS (
    SELECT dd::date AS dt
    FROM generate_series
            ('2010-01-01'::timestamp
            , '2030-01-01'::timestamp
            , '1 day'::interval) dd
)
SELECT
    to_char(dt, 'YYYYMMDD')::int AS id,
    dt AS date,
    to_char(dt, 'YYYY-MM-DD') AS ansi_date,
    date_part('isodow', dt)::int AS day,
    date_part('week', dt)::int AS week_number,
    date_part('month', dt)::int AS month,
    date_part('isoyear', dt)::int AS year,
    (date_part('isodow', dt)::smallint BETWEEN 1 AND 5)::int AS week_day,
    (to_char(dt, 'YYYYMMDD')::int IN (
        20130101,
        20130102,
        20130103,
        20130104,
        20130105,
        20130106,
        20130107,
        20130108,
        20130223,
        20130308,
        20130310,
        20130501,
        20130502,
        20130503,
        20130509,
        20130510,
        20130612,
        20131104,
        20140101,
        20140102,
        20140103,
        20140104,
        20140105,
        20140106,
        20140107,
        20140108,
        20140223,
        20140308,
        20140310,
        20140501,
        20140502,
        20140509,
        20140612,
        20140613,
        20141103,
        20141104,
        20150101,
        20150102,
        20150103,
        20150104,
        20150105,
        20150106,
        20150107,
        20150108,
        20150109,
        20150223,
        20150308,
        20150309,
        20150501,
        20150504,
        20150509,
        20150511,
        20150612,
        20151104,
        20160101,
        20160102,
        20160103,
        20160104,
        20160105,
        20160106,
        20160107,
        20160108,
        20160222,
        20160223,
        20160307,
        20160308,
        20160501,
        20160502,
        20160503,
        20160509,
        20160612,
        20160613,
        20161104,
        20170101,
        20170102,
        20170103,
        20170104,
        20170105,
        20170106,
        20170107,
        20170108,
        20170223,
        20170224,
        20170308,
        20170501,
        20170508,
        20170509,
        20170612,
        20171104,
        20171106,
        20180101,
        20180102,
        20180103,
        20180104,
        20180105,
        20180106,
        20180107,
        20180108,
        20180223,
        20180308,
        20180309,
        20180430,
        20180501,
        20180502,
        20180509,
        20180611,
        20180612,
        20181104,
        20181105,
        20181231,
        20190101,
        20190102,
        20190103,
        20190104,
        20190105,
        20190106,
        20190107,
        20190108,
        20190223,
        20190308,
        20190501,
        20190502,
        20190503,
        20190509,
        20190510,
        20190612,
        20191104,
        20200101, 20200102, 20200103, 20200106, 20200107, 20200108,
       20200224, 20200309, 20200501, 20200504, 20200505, 20200511,
       20200612, 20201104))::int AS holiday
FROM dates
ORDER BY dt;

ALTER TABLE bookings.Dim_Calendar ADD PRIMARY KEY (id);

create table bookings.Dim_Passengers (
id serial not null,
passenger_id int not null,
passenger_name varchar(100) not null,
CONSTRAINT id_pkey PRIMARY KEY (id)
)

create table bookings.Dim_Aircrafts
(
id serial not null,
aircraft_code bpchar(3) NOT NULL,
model jsonb NOT NULL,
range int4 NOT NULL,
CONSTRAINT aircrafts_pkey PRIMARY KEY (aircraft_code),
CONSTRAINT aircrafts_range_check CHECK ((range > 0))
)

create table bookings.Dim_Airports
(
id serial not null,
airport_code bpchar(3) NOT NULL,
airport_name jsonb NOT NULL,
city jsonb NOT NULL,
coordinates point NOT NULL,
timezone text NOT NULL,
CONSTRAINT airports_data_pkey PRIMARY KEY (airport_code)
)

create table bookings.Dim_Tariff
(
id serial not null,
fare_conditions varchar (10),
CONSTRAINT Tariff_pkey PRIMARY KEY (fare_conditions)
)

alter table bookings.fact_flights 
add constraint fact_flights_fk foreign key (passenger_id) references bookings.dim_passengers(id);

alter table bookings.fact_flights 
add constraint fact_flights_fare_conditions_fk foreign key (fare_conditions) references bookings.dim_tariff(fare_conditions);

alter table bookings.fact_flights 
add constraint fact_flights_aircraft_code_fk foreign key (aircraft_code) references bookings.dim_aircrafts(aircraft_code);

alter table bookings.fact_flights 
add constraint fact_flights_departure_airport_fk foreign key (departure_airport) references bookings.dim_airports(airport_code);

alter table bookings.fact_flights 
add constraint fact_flights_arrival_airport_fk foreign key (arrival_airport) references bookings.dim_airports(airport_code);


create table bookings.rejected_Fact_Flights (like bookings.Fact_Flights);
create table bookings.rejected_dim_aircrafts (like bookings.dim_aircrafts);
create table bookings.rejected_dim_airports (like bookings.dim_airports);
create table bookings.rejected_dim_passengers (like bookings.dim_passengers);
