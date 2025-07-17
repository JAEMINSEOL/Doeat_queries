with p_order as (select o.*
                 from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on o.team_order_id = t.id
                          join doeat_delivery_production.item i on i.order_id = o.id
                          join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
                 where o.orderyn = 1
                   and o.paid_at is not null
                   and o.delivered_at is not null
                   and t.is_test_team_order = 0
--                    and o.sigungu = '동작구'
--                    and o.type = 'DOEAT_DESSERT'
                   and o.created_at::date between '2025-06-26' and '2025-07-16'
                 )

, base as (select o.user_id
   , date_trunc('hour', o.created_at) as hour
   , sum(o.order_price) as price_sum
   , count(o.id) as order_sum
    from p_order o
    group by 1, 2
    )

select
    case when price_sum < 15000 then '0-15000'
        when price_sum between 15000 and 24900 then '15000-24900'
        when price_sum between 25000 and 29900 then '25000-29900'
        when price_sum between 30000 and 34900 then '30000-34900'
        when price_sum between 35000 and 39900 then '35000-39900'
        when price_sum between 40000 and 44900 then '40000-44900'
        when price_sum between 45000 and 49900 then '45000-49900'
        when price_sum between 50000 and 54900 then '50000-54900'
        when price_sum >= 55000 then '55000-'
        else null end as price_range
    , count(distinct user_id) as user_cnt
     , count(user_id) as order_cnt
     , sum(price_sum) as GTV
    from base b
    group by 1
    
    union all

select 
    '전체' as price_range
    , count(distinct user_id) as user_cnt
     , count(user_id) as order_cnt
     , sum(price_sum) as GTV
     from base b
     
    order by price_range
    
