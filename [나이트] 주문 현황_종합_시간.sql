with p_order as (select o.id,o.created_at,o.created_at::date as date,o.delivered_at, o.sigungu, u.user_name,p.menu_name, tor.rider_id, r.rider_name,o.status,o.type, o.store_id, i.product_id, o.order_price
from doeat_delivery_production.orders o
    join doeat_delivery_production.item i on i.order_id = o.id
    join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
    join doeat_delivery_production.user u on u.user_id=o.user_id
    left join (select * from doeat_delivery_production.team_order_rider tor where tor.is_deleted=0) tor on tor.team_order_id = o.team_order_id
    left join doeat_delivery_production.rider r on r.id = tor.rider_id
where o.orderyn=1
    and o.paid_at is not null
    and o.delivered_at is not null
    and o.status = 'DELIVERED'
    and (o.store_id in (6920,6921) or o.type in ('DOEAT_EVENT','DOEAT_OMAKASE'))
    and p.menu_name not like '%아메리카노%'
    and not (p.menu_name like '%하몽%' and o.order_price<20000)
    and not (p.menu_name like '%꼴딱이%' and o.order_price<20000)
    and o.created_at::date >= '{{시작날짜}}'

                     )

, s_order as(
select menu_name
        , extract('hour' from o.created_at) as hour
        , case when hour<5 then hour+24 else hour end as hour_24
            , count(distinct id) as 주문건수
            

        

    from p_order o
group by 1,2,3
order by 1 DESC,2
)

, s_order2 as (select *
        , sum(주문건수) over (partition by menu_name order by hour_24 rows between unbounded preceding and current row) as 누적주문건수
        from s_order
        order by hour_24)
        
select *
        , 누적주문건수 *100.0 / max(누적주문건수) over (partition by menu_name) as ratio
        from s_order2
        order by hour_24
