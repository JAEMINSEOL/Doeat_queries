
with 

-- PB 지표 계산

pb_amazing as (
     select a.date, a.sigungu
     , a.order_cnt_1p
     , like_cnt*100.0/survey_cnt as like_ratio
    from (
    select date(o.created_at) as date
    , sigungu
    , count(distinct case when type = 'CURATION_PB' then o.id end) as order_cnt_1p
    from doeat_delivery_production.orders o
    JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
    where date(o.created_at) >= '2025-01-01'
      and o.sigungu IN ('관악구', '동작구')
      AND o.delivered_at IS NOT NULL
      AND t.is_test_team_order = 0
      AND o.paid_at IS NOT NULL      
      and orderyn = 1
    group by 1,2
    ) a
    join (
    select date(created_at) as date
        , case when store_id=6280 then '관악구' when store_id=6773 then '동작구' end as sigungu
         , count(id) as survey_cnt
         , sum(case when feedback_type = 'LIKE' then 1 end) as like_cnt
         , like_cnt*100.0/survey_cnt as like_ratio
    from doeat_delivery_production.curation_feedback
    where store_id in (6280, 6773)
    group by 1,2) b on (a.date = b.date and a.sigungu = b.sigungu)
)
,
daily_data as (
    select a.date::date as start_date,
           a.date::date as end_date,
           a.date,
           '일' as period,
           a.sigungu,
           -- PB 지표
           a.order_cnt_1p,
           a.like_ratio
           -- 멤버십 지표
    from pb_amazing a
)

  SELECT
  start_date,
  end_date,
    sigungu,
    '일' as period,
    order_cnt_1p,
    like_ratio
  from daily_data d

  union all

  SELECT
    date(dateadd(day,-(extract(dayofweek from date::date)+left('3',1)::INT-1)%7,date::date))::date as start_date,
    (date(dateadd(day,-(extract(dayofweek from date::date)+left('3',1)::INT-1)%7,date::date)) + interval '6 days')::date as end_date,
        sigungu,
    '주-금목' as period,
    AVG(order_cnt_1p) as order_cnt_1p,
    AVG(like_ratio) as like_ratio
  from daily_data d
  group by 1,2,3
  
  union all
  
    SELECT
    date(dateadd(day,-(extract(dayofweek from date::date)+left('7',1)::INT-1)%7,date::date))::date as start_date,
    (date(dateadd(day,-(extract(dayofweek from date::date)+left('7',1)::INT-1)%7,date::date)) + interval '6 days')::date as end_date,
        sigungu,
    '주-월일' as period,
    AVG(order_cnt_1p) as order_cnt_1p,
    AVG(like_ratio) as like_ratio
  from daily_data d
  group by 1,2,3
  
  union all
  
    SELECT
    date_trunc('month',date::date)::date as start_date,
    (last_day(date::date))::date as end_date,
        sigungu,
    '월' as period,
    AVG(order_cnt_1p) as order_cnt_1p,
    AVG(like_ratio) as like_ratio
  from daily_data d
  group by 1,2,3
