## AGGREGATE DATA FROM MULTIPLE CSV FILES INTO SINGLE TABLE

drop table capstone;
create table capstone like jan_2024;

insert into capstone
select*from jan_2024;

insert into capstone
select*from feb_2024;

insert into capstone
select*from mar_2024;

insert into capstone
select*from apr_2024;

insert into capstone
select*from may_2024;

insert into capstone
select*from june_2024;

insert into capstone
select*from july_2024;

insert into capstone
select*from aug_2024;

insert into capstone
select*from sept_2024;

insert into capstone
select*from oct_2024;

insert into capstone
select*from nov_2024;

insert into capstone
select*from dec_2024;

## SETTING CORRECT DATA TYPES

alter table capstone
modify column started_at datetime;

alter table capstone
modify column ended_at datetime;

alter table capstone
modify column start_lat double;

alter table capstone
modify column end_lat double;

alter table capstone
modify column start_lng double;

alter table capstone
modify column end_lng double;

## REMOVING UNDERSCORE FROM RIDEABLE_TYPE

select distinct rideable_type from capstone;

update capstone
set rideable_type='electric bike' where rideable_type='electric_bike';
update capstone
set rideable_type='classic bike' where rideable_type='classic_bike';
update capstone
set rideable_type='electric scooter' where rideable_type='electric_scooter';

## REMOVING RIDES THAT STARTED AND ENDED AT SAME TIME &
## REMOVING RIDES WITH STARTING TIME LATER THAN ENDING TIME

select count(*)
from capstone
where started_at = ended_at or started_at > ended_at;

delete from capstone
where started_at = ended_at or started_at > ended_at;

## ADDING COLUMNS FOR RIDE TIME LENGTH

alter table capstone
add column ride_length_seconds double after ended_at;

update capstone
set ride_length_seconds=time_to_sec(timediff(ended_at,started_at));

alter table capstone
add column ride_length_minutes double after ride_length_seconds;

update capstone
set ride_length_minutes=round(ride_length_seconds/60,2);

alter table capstone
add column ride_length_hours double after ride_length_minutes;

update capstone
set ride_length_hours=round(ride_length_minutes/60,2);

## REMOVING INSIGNIFICANT RIDES <1 MINUTE

select count(*)
from capstone
where ride_length_seconds < 60;

delete from capstone
where ride_length_seconds < 60;

## CREATING RIDE START DAY OF WEEK COLUMN
alter table capstone
add column day_of_week_num double;

update capstone
set day_of_week_num=weekday(started_at);

alter table capstone
add column day_of_week text;

update capstone
set day_of_week='Monday'
where day_of_week_num=0;

update capstone
set day_of_week='Tuesday'
where day_of_week_num=1;

update capstone
set day_of_week='Wednesday'
where day_of_week_num=2;

update capstone
set day_of_week='Thursday'
where day_of_week_num=3;

update capstone
set day_of_week='Friday'
where day_of_week_num=4;

update capstone
set day_of_week='Saturday'
where day_of_week_num=5;

update capstone
set day_of_week='Sunday'
where day_of_week_num=6;

## CREATING COLUMN FOR DISTANCE, **1 degree of lat/long ~69 miles
## DISTANCES NOT LONG ENOUGH TO CONSIDER CURVATURE OF THE EARTH

alter table capstone
add column distance_miles double;
update capstone
set distance_miles=round(sqrt(power(end_lat-start_lat,2)+power(end_lng-start_lng,2))*69,4);

## CREATE T/F COLUMN DENOTING START AND END LOCATIONS DIFFER

alter table capstone
add column end_diff_location text;

update capstone
set end_diff_location = 'TRUE'
where start_lat != end_lat
or start_lng != end_lng;

update capstone
set end_diff_location = 'FALSE' 
where start_lat = end_lat
and start_lng = end_lng;

## SEARCH FOR DUPLICATE RIDE ID

select ride_id,row_number() over( partition by ride_id) as row_num
from capstone
order by row_num desc;

##SEARCH FOR BLANK RIDE ID

select*from capstone
where ride_id='' or ride_id=' ' or ride_id=NULL;
