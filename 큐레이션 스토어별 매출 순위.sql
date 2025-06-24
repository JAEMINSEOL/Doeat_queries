select
--     date(o.created_at) as date
    o.store_id
    , s.store_name
    , s.sigungu
    , s.hname
    , sum(o.order_price) as 기간매출액
    , rank() over (order by sum(o.order_price) desc) as 매출순위
    from doeat_delivery_production.orders o
    join doeat_delivery_production.team_order t on t.id = o.team_order_id
    join doeat_delivery_production.store s on s.id = o.store_id
    where
        o.orderyn=1
    and o.delivered_at is not null
    and o.paid_at is not null
    and t.is_test_team_order = 0
    and o.created_at::date >= '{{시작날짜}}'
    and (o.type like '%SEVEN%')
group by 1,2,3,4
order by 매출순위
limit 50
