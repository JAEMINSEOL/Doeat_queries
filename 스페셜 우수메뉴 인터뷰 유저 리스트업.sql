with p_order as (select o.id, o.user_id,o.created_at,menu_name, store_name,
                        count(i.id) as o_i_cnts
                        , listagg(p.menu_name::varchar , '; ') as o_items
                 , sum(o.order_price) as o_price
                 from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on o.team_order_id = t.id
                          join doeat_delivery_production.item i on i.order_id = o.id
                          join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
                          join doeat_delivery_production.store s on s.id = o.store_id
                 where o.orderyn = 1
                   and o.paid_at is not null
                   and o.delivered_at is not null
                   and t.is_test_team_order = 0
--                    and o.sigungu = '관악구'
                   and o.type like '%119%'
                   and o.created_at >= '2025-06-16'
                 group by 1,2,3,4,5)

    , p_user as (select u.*
                 from doeat_delivery_production.user u
                 join doeat_delivery_production.user_address ad on u.user_id = ad.user_id
                 where u.gender in ('M','F')
                 and u.authority = 'GENERAL'
--                      and ad.is_main_address =1
--                  and ad.sigungu = '관악구'
                 )

, summary as (select 
    o.id as order_id

    , u.user_id
    , o.created_at::date as date
    , o.store_name
    , o.o_items
    , o.o_price::int as price
    , u.birth_date
    , u.gender
    , u.user_phone
    , u.user_name
    , count(o.id) over (partition by u.user_id) as order_cnt

--     , count(o.id) as order_cnt
    , avg(o.o_i_cnts-1.00) over (partition by u.user_id) as option_addon_rate
--     , listagg(o.id::varchar, '; ') as o_id_list
--     , listagg(date(o.created_at), '; ') as o_dates
--     , listagg(o.store_name::varchar, '; ') as store_names
--     , listagg(o.o_items::varchar, '; ') as menu_names
-- , listagg(o.o_price::varchar, '; ') as menu_price





from p_order o
join p_user u on u.user_id = o.user_id
-- group by 1,2,3,4,5
-- having order_cnt >=3
order by order_cnt desc
)

select * from summary 
where order_cnt>=3
