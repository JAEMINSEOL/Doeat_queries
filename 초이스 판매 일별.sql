with
p_order as (
            select o.*,i.product_id,p.menu_name
            from doeat_delivery_production.orders o
            join doeat_delivery_production.team_order t on t.id = o.team_order_id
            join doeat_delivery_production.item i on i.order_id=o.id
            join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
            where o.orderyn=1
            and o.paid_at is not null
            and o.delivered_at is not null
            and t.is_test_team_order=0
            and o.type = 'DOEAT_CHOICE'
--             and o.created_at::date = current_date
            )
select created_at::date as date
        , isnull(menu_name,'전체')
        , count(distinct id) as ord_cnt
        , avg(order_price) as aov
from p_order
group by rollup(menu_name), date
