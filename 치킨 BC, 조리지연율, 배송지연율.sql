SELECT b.*, a.bc_3p_chicken
from (
    select start_date as date, sigungu,bc_3p_chicken
    from doeat_data_mart.mart_bc
    where period = '일'
      and start_date >= '{{시작 날짜}}'
      and sigungu = '{{지역}}'
) a
LEFT JOIN (
    SELECT
        mt.operation_date as date,
        case when o.sigungu in ('구로구', '금천구') then '구로금천구' else o.sigungu end as sigungu,
        -- 치킨 배송지연율
        count(distinct case when o.type like '%CHICKEN%' then o.id end) as chicken_order_cnt,
        avg(case when o.type like '%CHICKEN%' then datediff(second, t.complete_at, t.expect_cooking_time)/60.0 end) as avg_cooking_duration,
        count(case when o.type like '%CHICKEN%' and datediff(second, t.complete_at, t.expect_cooking_time)/60.0 >= 25 then o.id end) * 100.0 / nullif(chicken_order_cnt, 0) as chicken_late_cooking_25_rate_ratio,
        count(case when o.type like '%CHICKEN%' and datediff(second, t.complete_at, t.expect_cooking_time)/60.0 >= 30 then o.id end) * 100.0 / nullif(chicken_order_cnt, 0) as chicken_late_cooking_30_rate_ratio,
        avg(case when o.type like '%CHICKEN%' then datediff(second, o.paid_at, o.delivered_at)/60.0 end) as avg_delivery_duration,
        count(case when o.type like '%CHICKEN%' and datediff(second, o.paid_at, o.delivered_at)/60.0 >= 55 then o.id end) * 100.0 / nullif(chicken_order_cnt, 0) as chicken_late_delivery_55_ratio,
        count(case when o.type like '%CHICKEN%' and datediff(second, o.paid_at, o.delivered_at)/60.0 >= 60 then o.id end) * 100.0 / nullif(chicken_order_cnt, 0) as chicken_late_delivery_60_ratio
        
       FROM doeat_delivery_production.orders o
    JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
    LEFT JOIN doeat_data_mart.mart_date_timeslot_general mt ON date(o.created_at) = mt.date AND extract(hour from o.created_at) = mt.hour
    WHERE o.orderyn = 1
      AND o.delivered_at IS NOT NULL
      AND o.paid_at IS NOT NULL
      AND t.is_test_team_order = 0
      AND mt.operation_date >= '{{시작 날짜}}'
      AND sigungu = '{{지역}}'
    GROUP BY 1, 2
) b on(a.date = b.date and a.sigungu = b.sigungu)
order by a.date desc, a.sigungu                
