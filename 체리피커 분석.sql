with      
p_order as (select * from (select o.*
                , row_number() over (partition by user_id order by o.created_at) as ord_num
                , MIN(o.created_at) OVER (PARTITION BY user_id) AS first_order_date
        from doeat_delivery_production.orders o
        join doeat_delivery_production.team_order t on t.id = o.team_order_id
        where orderyn=1
        and o.paid_at is not null
        and o.delivered_at is not null
        and t.is_test_team_order = 0) o
        where datediff('day',first_order_date, o.created_at) <= 7
)
, p_user as (
    select u.*,ad.sigungu, ad.hname,ad.address_name
    from doeat_delivery_production.user u
    join doeat_delivery_production.user_address ad on u.user_id = ad.user_id
    where u.authority = 'GENERAL'
    and u.created_at::date >= '2025-03-01'
    and ad.is_main_address=1
)

select u.user_id, u.gender, u.birth_date, u.user_name
        , case when ord_cnt>=3 then '>=3' else ord_cnt::text end as "가입 첫 주 주문수"
        , o.order_price, c.coupon_name, o.discount_price
        , case when o.type = 'CURATION_PB' then 'Amazing'
            when o.type like '%SEVEN%' then 'Today'
            when o.type like '%119%' then 'Special'
            when o.type = 'TEAMORDER' then 'General'
            when o.type like '%CHICKEN%' then 'Chicken'
            when o.type like '%DESSERT%' then 'Dessert'
            else 'Event' end as type
        , case when order_price <7900 then '0-7800'
            when order_price between 7900 and 9800 then '7900-9800'
            when order_price between 9900 and 12800 then '9900-12800'
            when order_price between 12900 and 14900 then '12900-14900'
            when order_price between 15000 and 19900 then '15000-19900'
            when order_price between 20000 and 29900 then '20000-29900'
            -- when order_price between 30000 and 39900 then '30000-39900'
            when order_price >= 30000 then '>30000' end as price
from (select u.user_id,
             user_name,
             u.created_at,
             count(distinct o.id) as ord_cnt
      from p_user u
               join p_order o on o.user_id = u.user_id
      group by 1, 2, 3
      having ord_cnt !=2
      ) uo
join p_user u on uo.user_id = u.user_id
join p_order o on o.user_id = u.user_id
join doeat_delivery_production.user_coupon uc on uc.id = o.coupon_id
join doeat_delivery_production.coupon c on c.id = uc.coupon_id

where c.coupon_name like '%웰컴%'
and ord_num = 1
order by ord_cnt, user_name
-- group by 1,2,3,5,6,7
