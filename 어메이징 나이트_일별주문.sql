with p_order as (select o.id
                      , product_id
                      , menu_name
                      , mt.operation_date as date
                      , case when o.store_id in (6909, 6919, 6920) then '관악' when o.store_id = 6921 then '동작' end as store
--             o.id as order_id, o.created_at, i.product_id
                 from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on t.id = o.team_order_id
                          join doeat_delivery_production.item i on i.order_id = o.id
                          join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
                          join doeat_delivery_production.store s on s.id = o.store_id
                          join doeat_data_mart.mart_date_timeslot_general mt
                               ON DATE(o.created_at) = mt.date AND EXTRACT(hour FROM o.created_at) = mt.hour
                 where o.orderyn = 1
                   and o.paid_at is not null
                   and o.delivered_at is not null
                   and t.is_test_team_order = 0
                   and i.product_id is not null
                   and product_type = 'AMAZING_NIGHT'
                 order by 4)
select date, date_trunc('week',date) as week,extract('dow' from date) as dow, menu_name, ord_cnt_total, ord_cnt_gwanak, ord_cnt_dongjak
from(
select date, menu_name
, count(distinct id) as ord_cnt_total
        , count(distinct case when store='관악' then id end) as ord_cnt_gwanak
         , count(distinct case when store='동작' then id end) as ord_cnt_dongjak
from p_order
group by 1,2
order by date
)

