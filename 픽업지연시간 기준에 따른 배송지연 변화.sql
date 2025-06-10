with base as (select
          o.id
          , datediff(second,
                      (case
                          when t.rider_pick_up_time < t.expect_cooking_time then rider_arrival_time
                          else greatest(t.rider_arrival_time, t.expect_cooking_time) end), t.rider_pick_up_time) / 60.0
                                                                  as pickup_wait
          , datediff(second, o.paid_at, o.delivered_at) / 60.0    as actual_dex_time
              from doeat_delivery_production.orders o
                      join doeat_delivery_production.team_order t on o.team_order_id = t.id
        
              where o.orderyn = 1
                and o.paid_at is not null
                and o.delivered_at is not null
                and o.type = 'CURATION_PB'
                and date(o.created_at) >= '2025-06-01'
                and t.is_test_team_order = 0)
        ,
  gs AS (
        SELECT 1 AS thr UNION ALL
        SELECT 2       UNION ALL
        SELECT 3       UNION ALL
        SELECT 4       UNION ALL
        SELECT 5       UNION ALL
        SELECT 6       UNION ALL
        SELECT 7       UNION ALL
        SELECT 8       UNION ALL
        SELECT 9       UNION ALL
        SELECT 10
      )



select
gs.thr as 픽업_지연_시간_기준
, avg(actual_dex_time) as 기존_배송_시간
, avg(actual_dex_time - pickup_wait + least(pickup_wait, gs.thr))as 조정_배송_시간
, avg(actual_dex_time) - 조정_배송_시간 as 배송_시간_감소량
, count(case when actual_dex_time>=55 then id end)*100.0 /  count(id) as 기존_배송_지연률
,  count(case when (actual_dex_time - pickup_wait + least(pickup_wait, gs.thr))>=55 then id end)*100.0 / count(id) as 조정_배송_지연률
, 기존_배송_지연률 - 조정_배송_지연률 as 배송_지연률_감소량

from base as o
cross join gs

group by gs.thr
order by gs.thr

