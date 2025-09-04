
SELECT
    mt.operation_date as date,
    o.sigungu,

    -- 치킨 조리지연율
    count(distinct case when o.type like '%CHICKEN%' then o.id end) as chicken_order_cnt,
    count(case when o.type like '%CHICKEN%' and datediff(second, t.complete_at, t.expect_cooking_time)/60.0 >= 25 then o.id end) * 100.0 / nullif(chicken_order_cnt, 0) as chicken_late_cooking_25_rate_ratio,
    count(case when o.type like '%CHICKEN%' and datediff(second, t.complete_at, t.expect_cooking_time)/60.0 >= 30 then o.id end) * 100.0 / nullif(chicken_order_cnt, 0) as chicken_late_cooking_30_rate_ratio
    
   FROM doeat_delivery_production.orders o
JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
LEFT JOIN doeat_data_mart.mart_date_timeslot_general mt ON date(o.created_at) = mt.date AND extract(hour from o.created_at) = mt.hour
WHERE o.orderyn = 1
  AND o.delivered_at IS NOT NULL
  AND o.paid_at IS NOT NULL
  AND t.is_test_team_order = 0
  AND o.sigungu in ({{지역}})
  AND mt.operation_date >= '{{시작 날짜}}'
GROUP BY 1, 2
                
