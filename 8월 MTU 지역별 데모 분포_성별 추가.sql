select
    case
        when age <= 20 then '0-19'
        when age between 20 and 24 then '20-24'
        when age between 25 and 29 then '25-29'
        when age between 30 and 34 then '30-34'
        when age between 35 and 39 then '35-39'
        when age between 40 and 44 then '40-44'
        when age between 45 and 49 then '45-49'
        when age between 50 and 54 then '50-54'
        when age between 55 and 59 then '55-59'
        when age >= 60 then '60+'
        else 'unknown' end as age_group
    , gender
    , count(distinct user_id) as user_cnt_all
    , user_cnt_all*100.0/nullif(sum(user_cnt_all) over(),0) as user_pct_all
    , case when age_group != 'unknown' then user_cnt_all end*100.0/nullif(sum(case when age_group != 'unknown' then user_cnt_all end) over(),0) as user_pct_all
    , count(distinct case when sigungu = '관악구' then user_id end) as user_cnt_gwanak
    , user_cnt_gwanak*100.0/nullif(sum(user_cnt_gwanak) over(),0) as user_pct_gwanak
    , case when age_group != 'unknown' then user_cnt_gwanak end*100.0/nullif(sum(case when age_group != 'unknown' then user_cnt_gwanak end) over(),0) as user_pct_gwanak
    , count(distinct case when sigungu = '동작구' then user_id end) as user_cnt_dongjak
    , user_cnt_dongjak*100.0/nullif(sum(user_cnt_dongjak) over(),0) as user_pct_dongjak
    , case when age_group != 'unknown' then user_cnt_dongjak end*100.0/nullif(sum(case when age_group != 'unknown' then user_cnt_dongjak end) over(),0) as user_pct_dongjak
    , count(distinct case when sigungu in ('구로구','금천구') then user_id end) as user_cnt_guro_geumcheon
    , user_cnt_guro_geumcheon*100.0/nullif(sum(user_cnt_guro_geumcheon) over(),0) as user_pct_guro_geumcheon
    , case when age_group != 'unknown' then user_cnt_guro_geumcheon end*100.0/nullif(sum(case when age_group != 'unknown' then user_cnt_guro_geumcheon end) over(),0) as user_pct_guro_geumcheon
    , count(distinct case when sigungu in ('영등포구') then user_id end) as user_cnt_yeongdeungpo
    , user_cnt_yeongdeungpo*100.0/nullif(sum(user_cnt_yeongdeungpo) over(),0) as user_pct_yeongdeungpo
    , case when age_group != 'unknown' then user_cnt_yeongdeungpo end*100.0/nullif(sum(case when age_group != 'unknown' then user_cnt_yeongdeungpo end) over(),0) as user_pct_yeongdeungpo
from (
    select sigungu, o.user_id,gender
        , case
            when u.birth_date ~ '^[0-9]{6}$'
                then date_part('year', current_date) - case when substring(birth_date::varchar,1,2)::int > 30 then 1900 + substring(birth_date::varchar,1,2)::int else 2000 + substring(birth_date::varchar,1,2)::int end end as age
        , count(o.id) as order_cnt
    from doeat_delivery_production.orders o
    join doeat_delivery_production.team_order t on o.team_order_id = t.id
    join doeat_delivery_production.user u on o.user_id = u.user_id
    where o.orderyn = 1
      and t.is_test_team_order = 0
      and o.paid_at is not null
      and o.delivered_at is not null
      and date(o.created_at) between '2025-08-01' and '2025-08-31'
      and gender in ('M','F')
    group by 1,2,3,4) a
group by 1,2
order by 1
