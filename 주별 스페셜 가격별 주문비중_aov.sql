select date_trunc('week',o.created_at)::date as week
        , count(distinct o.id) as special_ord_cnt
        , avg(order_price) as aov
        , count(distinct case when order_price = 9900 then o.id end)*100.0 / count(distinct o.id) as special_9900_ord_rate
, count(distinct case when order_price = 12900 then o.id end)*100.0 / count(distinct o.id) as special_12900_ord_rate
, count(distinct case when order_price = 16900 then o.id end)*100.0 / count(distinct o.id) as special_16900_ord_rate
from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on t.id = o.team_order_id
join doeat_delivery_production.item i on i.order_id = o.id
where o.orderyn=1
and o.paid_at is not null
and o.delivered_at is not null
and t.is_test_team_order=0
and o.sigungu = '관악구'
and o.type like '%119%'
group by 1
order by week desc
