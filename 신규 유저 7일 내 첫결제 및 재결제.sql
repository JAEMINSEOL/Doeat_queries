with p_order as (select date_trunc('week',dateadd('day',3,o.created_at)) as week, o.id, o.user_id
                 from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on o.team_order_id = t.id
                          join doeat_delivery_production.item i on i.order_id = o.id
                          join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
                 where o.orderyn = 1
                   and o.paid_at is not null
                   and o.delivered_at is not null
                   and t.is_test_team_order = 0
                   
                   
                   )

    , p_user as (select date_trunc('week',dateadd('day',3,u.created_at)) as week, u.user_id
                 from doeat_delivery_production.user u
                 join doeat_delivery_production.user_address ad on u.user_id = ad.user_id
                 where authority = 'GENERAL'
                --  and u.gender in ('M','F')
                 and ad.is_main_address =1
                 and ad.sigungu = '{{시군구}}'
                 and u.created_at >= '2025-03-01'
                 )
    , base as (select dateadd('day',4,u.week) as week
                        , u.user_id
                        , count(distinct o.id) as ord_cnt
                from p_user u
                left join p_order o on o.user_id=u.user_id and o.week =u.week
                group by u.week, u.user_id
                order by u.week desc
    )
    
    select week
            , count(distinct user_id) as total_user
            , count(distinct case when ord_cnt>=1 then user_id end) as first_ord
            , count(distinct case when ord_cnt>=2 then user_id end) as re_ord
            , first_ord*100.0/total_user as first_ord_rate
            , re_ord*100.0/total_user as re_ord_rate
    from base
    group by week
    order by week desc
