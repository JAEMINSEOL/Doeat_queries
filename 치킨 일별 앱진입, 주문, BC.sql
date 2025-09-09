with log_data as (
    select dt as date, sigungu,
           count(distinct l.user_id) as app_enter_user_cnt
           from service_log.user_log l
           join (select u.user_id,sigungu 
                   from doeat_delivery_production.user u
                   join doeat_delivery_production.user_address ad on ad.user_id=u.user_id
                    where ad.is_main_address=1
                    and sigungu in ('관악구','동작구')
           ) u on u.user_id = l.user_id
    where dt >= '2025-08-01'
    group by 1,2 
)
,

order_data as (
    SELECT date(o.created_at) as date,sigungu,
           count(distinct o.user_id) as order_user_cnt
    FROM doeat_delivery_production.orders o
    JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
    WHERE o.type = 'DOEAT_CHICKEN'
        and o.status not in ('CANCEL', 'WAIT')
        and date(o.created_at) >= '2025-08-01'
        and o.sigungu in ('관악구','동작구')
    group by 1,2
)
select a.*, order_user_cnt,
    order_user_cnt * 100.0 / NULLIF(app_enter_user_cnt, 0) as "앱진입to결제전환율"   
    -- , order_user_cnt * 100.0 / NULLIF(page_enter_user_cnt, 0) as "X3.페이지진입to결제전환율"    
from log_data a
left join order_data b on a.date = b.date and a.sigungu=b.sigungu
order by date desc
