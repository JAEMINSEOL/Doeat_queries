
with 

-- PB 지표 계산

pb_amazing as (
     select a.date, a.sigungu
     , a.order_cnt_1p
     , like_cnt
     , survey_cnt
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
user_1p as (
select a.date
        , a.sigungu
        , count(distinct a.user_id) as paid_mbs_user_cnt
        , count(distinct b.user_id) as order_1p_user_cnt
        , order_1p_user_cnt *100.0 / paid_mbs_user_cnt as order_1p_user_cnt_rate
        from (
            select date::date
                    , a.user_id
                    , b.sigungu
            from doeat_data_mart.mart_membership a
            join doeat_delivery_production.user_address b on a.user_id = b.user_id
            ) a
        left join (
            select distinct date(o.created_at) as date
                    , user_id
            from doeat_delivery_production.orders o
            join doeat_delivery_production.team_order t on o.team_order_id = t.id
            where o.orderyn=1
                and o.delivered_at is not null
                and t.is_test_team_order=0
                and o.store_id in (6280,6773)

            ) b on a.user_id = b.user_id and a.date >= b.date
        group by 1,2
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
           like_cnt*100.0 / survey_cnt as like_ratio
                , like_cnt
     , survey_cnt
           -- 멤버십 지표
    , order_1p_user_cnt_rate
    from pb_amazing a
    join user_1p b on a.date = b.date and a.sigungu = b.sigungu
)
  SELECT
  start_date,
  end_date,
    sigungu,
    '일' as period,
    order_cnt_1p,
    like_ratio,
    order_1p_user_cnt_rate
  from daily_data d

  union all

  SELECT
    date(dateadd(day,-(extract(dayofweek from date::date)+left('3',1)::INT-1)%7,date::date))::date as start_date,
    (date(dateadd(day,-(extract(dayofweek from date::date)+left('3',1)::INT-1)%7,date::date)) + interval '6 days')::date as end_date,
        sigungu,
    '주-금목' as period,
    AVG(order_cnt_1p) as order_cnt_1p,
    sum(like_cnt)*100.0  / sum(survey_cnt) as like_ratio,
    avg(order_1p_user_cnt_rate) as order_1p_user_cnt_rate
  from daily_data d
  group by 1,2,3
  
  union all
  
    SELECT
    date(dateadd(day,-(extract(dayofweek from date::date)+left('7',1)::INT-1)%7,date::date))::date as start_date,
    (date(dateadd(day,-(extract(dayofweek from date::date)+left('7',1)::INT-1)%7,date::date)) + interval '6 days')::date as end_date,
        sigungu,
    '주-월일' as period,
    AVG(order_cnt_1p) as order_cnt_1p,
    sum(like_cnt)*100.0  / sum(survey_cnt) as like_ratio
    , avg(order_1p_user_cnt_rate) as order_1p_user_cnt_rate
  from daily_data d
  group by 1,2,3
  
  union all
  
    SELECT
    date_trunc('month',date::date)::date as start_date,
    (last_day(date::date))::date as end_date,
        sigungu,
    '월' as period,
    AVG(order_cnt_1p) as order_cnt_1p,
    sum(like_cnt)*100.0  / sum(survey_cnt) as like_ratio
    , avg(order_1p_user_cnt_rate) as order_1p_user_cnt_rate
  from daily_data d
  group by 1,2,3
