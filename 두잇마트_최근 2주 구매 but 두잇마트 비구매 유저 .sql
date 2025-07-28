with p_order as (select o.created_at, u.user_id, u.user_name, u.user_phone, u.gender, u.birth_date
        , case when o.type = 'FLASH_MART' then 1 else 0 end as mart_order
        , case when substring(u.birth_date, 1, 2)::int <= 24
                            then 2025 - (2000 + substring(u.birth_date, 1, 2)::int)
                        else 2025 - (1900 + substring(u.birth_date, 1, 2)::int)
                 end as age
from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on o.team_order_id = t.id
join doeat_delivery_production.item i on i.order_id = o.id
join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
join doeat_delivery_production.user u on u.user_id = o.user_id
where o.orderyn=1
    and o.paid_at is not null
    and o.delivered_at is not null
    and t.is_test_team_order = 0
    and o.created_at>'2025-07-14'
    and u.gender in ('M','F')
    and u.birth_date ~ '^[0-9]+$'
    and u.authority = 'GENERAL'
    )

select user_id, user_name, user_phone, gender, birth_date
        , case when substring(birth_date, 1, 2)::int <= 24
            then 2025 - (2000 + substring(birth_date, 1, 2)::int)
            else 2025 - (1900 + substring(birth_date, 1, 2)::int)
             end as age
        , rand(substring(user_id,5,5)::int) as r1
        , max(mart_order) as has_order_mart
from p_order
group by 1,2,3,4,5,6,7
having has_order_mart=0
order by r1
limit 70
