select date
        , count(date) as cnt_orders
        , avg(total_price) as aov
        , sum(total_price) as gtv
        , sum(cost_price) as cogs
        , max(rider_cost) as total_rider_cost
        , gtv-cogs-total_rider_cost as gp
from (select distinct date,name,total_price,cost_price,rider_cost,is_canceled from doeat_data_mart.orders_doeat_office) oo
where is_canceled=0 or is_canceled is null
group by date



-- select * from doeat_data_mart.orders_doeat_office
-- where date = '2025-07-15'
-- -- and (is_canceled=0 or is_canceled is null)
