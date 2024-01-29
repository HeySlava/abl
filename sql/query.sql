drop table if exists dinis;

create table if not exists dinis as 
with C as (
select 30000.0 as price
, 2000 as fixed_price
, 15 as fixed_minutes
),
calc as (
select 
	user_id 
	, first_name 
	, last_name 
	, CEIL(game_time / 60) game_time_minutes
	, tour
	, CEIL(C.price / COUNT(user_id) over w) cost_now
	, ceil((C.price / (48 * 5 * 60)) * game_time) cost_per_second
	, CEIL(CASE 
		when game_time < C.fixed_minutes * 60 then C.fixed_price
		else 
		(C.price - ((COUNT(user_id) over w - sum(CASE when (game_time > C.fixed_minutes * 60) then 1 else 0 END) over w) * C.fixed_price))
			/ (sum(CASE when (game_time > C.fixed_minutes * 60) then 1 else 0 END) over w)
	end) as with_fixed_price
from users u, C
where 1=1
	and team_id = 6112
window w as (PARTITION by tour, team_id)
)
select
	calc.*
	, cost_now - calc.cost_per_second as diff_1
	, cost_now - calc.with_fixed_price as diff_2
	, sum(calc.cost_per_second) over w check_1
	, sum(calc.with_fixed_price) over w check_2
	, sum(cost_now) over w1 as total_now
	, sum(cost_per_second) over w1 as total_per_second
	, sum(with_fixed_price) over w1 as total_with_fixed_price
from calc
where 1=1
window 
	w as (PARTITION by tour)
	, w1 as (PARTITION by user_id)
order by tour;


select * from dinis;

