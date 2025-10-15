select u.start_date as date, u.sigungu, rolling_30d_transaction_user_cnt, 
        sum(ord_cnt) as rolling_30d_ord_cnt,
        rolling_30d_ord_cnt *1.0 / rolling_30d_transaction_user_cnt as rolling_30d_frequency

from (
    select start_date::date as start_date, sigungu
        , rolling_30d_transaction_user_cnt
    from doeat_data_mart.mart_user_cnt
    where start_date >= '2025-08-24'
      and period = '일'
      and sigungu !='전체'
) u

left join(
    select o.created_at::date as start_date, o.sigungu
    , count(distinct o.id) as ord_cnt
    from doeat_delivery_production.orders o
        join doeat_delivery_production.team_order t on o.team_order_id = t.id
    where 1
        and o.orderyn=1
        and o.paid_at is not null
        and o.delivered_at is not null
        and t.is_test_team_order is not null
    group by start_date, sigungu
    ) o on u.sigungu = o.sigungu and (o.start_date between dateadd('day',-29,u.start_date) and u.start_date)
        
where u.sigungu in ('관악구', '동작구')
group by 1,2,3
order by date desc
