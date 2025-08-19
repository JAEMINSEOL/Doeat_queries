with
    p_order as( select o.*, i.menu_id, m.menu_name, p.sub_type, s.store_name as store_name
             from doeat_delivery_production.orders o
             join doeat_delivery_production.team_order t on t.id = o.team_order_id
             join doeat_delivery_production.team_order_rider tor on tor.team_order_id = o.team_order_id
             join doeat_delivery_production.item i on i.order_id = o.id
             join doeat_delivery_production.menu m on m.id = i.menu_id
             join doeat_delivery_production.store s on s.id = o.store_id
             left join doeat_delivery_production.doeat_777_product p on i.product_id=p.id
             where o.orderyn=1
             and o.paid_at is not null
             and o.delivered_at is not null
             and (o.type = 'TEAMORDER' or o.type = 'DOEAT_CHICKEN' or o.type like '%119%')
             and o.created_at::date between '2025-08-01' and dateadd('day',-1,current_date)
             and not ((o.type like '%119%' or o.type = 'DOEAT_CHICKEN' ) and sub_type is null)
             and o.sigungu = '관악구'
             )
, base as(
select o.created_at::date as date, menu_id, menu_name, store_name
     , case when type = 'TEAMORDER' then 'general' when type like '%119%' then 'special' when type='DOEAT_CHICKEN' then 'chicken' end as type
     , sub_type ,count(distinct o.id) as ord_cnt
           from p_order o
           group by 1, 2, 3,4,5,6)
select * from  (
select date, type, sub_type,store_name,menu_name, ord_cnt, row_number() over (partition by date, type order by ord_cnt desc) as rank
from base
)
where rank<=100

