
select menu_name, floor(pickup_wait_mins) AS wait_min_bin
, count(id) as items
from (
select o.id
                       , o.sigungu
                       , date(o.created_at)                                                  as date
                       , p.menu_name
                       ,  t.expect_cooking_time
                       , t.rider_arrival_time 
                       , t.rider_pick_up_time
                       , datediff(second, (case when t.rider_pick_up_time < t.expect_cooking_time then rider_arrival_time else greatest(t.rider_arrival_time,t.expect_cooking_time) end), t.rider_pick_up_time) / 60.0 as pickup_wait_mins
                  from doeat_delivery_production.orders o
                           join doeat_delivery_production.team_order t on (o.team_order_id = t.id)
                           join doeat_delivery_production.item i on (o.id = i.order_id)
                           join doeat_delivery_production.store s on s.id = t.store_id
                           join doeat_delivery_production.doeat_777_product p on (p.id = i.product_id)
                  where o.orderyn = 1
                    and o.paid_at is not null
                    and o.delivered_at is not null
                    and o.type = 'CURATION_PB'
                    and s.id = 6280
                    and date(o.created_at) >= '2025-06-01'
                    and t.is_test_team_order = 0
                    and pickup_wait_mins > 0
                  order by 8 asc
                             ) o

where                  
group by 1,2
