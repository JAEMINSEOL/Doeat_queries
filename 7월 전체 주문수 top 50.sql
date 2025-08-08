with 
p_order as (select o.*, m.menu_name
                from doeat_delivery_production.orders o
                    join doeat_delivery_production.team_order t on t.id = o.team_order_id
                    left join doeat_delivery_production.item i on i.order_id = o.id
                    left join doeat_delivery_production.menu m on m.id = i.menu_id
                where o.orderyn=1
                    and o.paid_at is not null
                    and o.delivered_at is not null
                    and t.is_test_team_order =0
                    and o.created_at::date >= '2025-06-01'
                )
, heavy_user as (select user_id
                , count (distinct case when o.type='CURATION_PB' then o.id end) as ord_cnt_pb
                , rank() over (order by ord_cnt_pb desc) as rank_pb
                , count (distinct o.id) as ord_cnt_all
                , rank() over (order by ord_cnt_all desc) as rank_all
                from p_order o
                where o.created_at::date between '2025-07-01' and '2025-07-31'
                group by 1
                )

select hu.rank_all, hu. ord_cnt_all, u.user_id, user_name, gender, birth_date
        , o.created_at, o.type, menu_name, o.address
from heavy_user hu
join doeat_delivery_production.user u on hu.user_id = u.user_id
join p_order o on o.user_id = hu.user_id
where hu.rank_all <= 50
and o.created_at::date between '2025-06-01' and current_date
and u.authority = 'GENERAL'

order by rank_all, user_id, created_at
