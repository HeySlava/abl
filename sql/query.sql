drop table if exists users;

CREATE TABLE IF NOT EXISTS users (
                tournament_team_user_id INTEGER,
                team_id INTEGER,
                game_time REAL,
                first_name TEXT,
                last_name TEXT,
                user_id INTEGER,
                team_name TEXT,
                sport_id INTEGER,
                tour INTEGER);

.mode csv
.headers on
.separator ,
.import data/users.csv users

drop table if exists costs;
create table if not exists costs as
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
	, cost_now - calc.cost_per_second as diff_cost_per_second
	, cost_now - calc.with_fixed_price as diff_with_fixed_price
	, sum(calc.cost_per_second) over w check_cost_per_second
	, sum(calc.with_fixed_price) over w check_with_fixed_price
	, sum(cost_now) over w1 as total_now
	, sum(cost_per_second) over w1 as total_per_second
	, sum(with_fixed_price) over w1 as total_with_fixed_price
from calc
where 1=1
window
	w as (PARTITION by tour)
	, w1 as (PARTITION by user_id)
order by tour;
