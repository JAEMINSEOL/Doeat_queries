with
base as (
        select  h.hackle_value,o.*
        from doeat_delivery_production.orders o
        join doeat_delivery_production.team_order t on t.id = o.team_order_id
        join doeat_delivery_production.item i on i.order_id = o.id
        join doeat_delivery_production.user u on u.user_id = o.user_id
        join doeat_delivery_production.user_hackle h on h.user_id = u.user_id
        join doeat_delivery_production.user_address ad on ad.user_id = u.user_id
        where o.orderyn=1
        and o.paid_at is not null
        and o.delivered_at is not null
        and t.is_test_team_order=0
        and o.type='DOEAT_CHICKEN'
        and authority = 'GENERAL'
        and ad.is_main_address =1
        and o.sigungu in ('관악구','동작구')
        and exp_name = 'chicken-promotion-1000-experiment'

)

select sigungu,hackle_value
        , avg(case when type='DOEAT_CHICKEN' then order_price end) as aov
        , count(distinct id) as ord_cnt_total
        , count(distinct case when order_price>13000 then id end) as ord_cnt_option
        from base
        where created_at::date between '2025-08-08' and '2025-08-14' 
        group by 1,2

union all

select '전체' as sigungu,hackle_value
        , avg(case when type='DOEAT_CHICKEN' then order_price end) as aov
        , count(distinct id) as ord_cnt_total
        , count(distinct case when order_price>13000 then id end) as ord_cnt_option
        from base
        where created_at::date between '2025-08-08' and '2025-08-14' 
        group by 1,2
        
    order by sigungu, hackle_value
