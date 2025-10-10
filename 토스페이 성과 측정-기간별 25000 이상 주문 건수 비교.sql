select case when o.created_at::date >= '2025-09-17' then '0917-0930' else '0903-0916' end as period
        , count(distinct o.id) as "총 주문 수"
        , count(distinct case when o.order_price >= 25000 then o.id end) as "25000원 이상 주문 수"
        , "25000원 이상 주문 수" *100.0 / "총 주문 수" as "25000원 이상 주문 비율"
from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on t.id = o.team_order_id
where o.orderyn=1
and o.paid_at is not null
and o.delivered_at is not null
and t.is_test_team_order = 0
and o.created_at::date between '2025-09-03' and '2025-09-30'
group by 1
order by 1
