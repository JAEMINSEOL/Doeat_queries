with p_order as (
    select o.id, o.created_at, o.user_id, o.order_price, o.team_order_id
        , h.doeat_777_delivery_sector_id as sector_id
    from doeat_delivery_production.orders o
    join doeat_delivery_production.team_order t on t.id = o.team_order_id
    join doeat_delivery_production.hdong h on h.name = o.hname
    where orderyn=1
        and o.paid_at is not null
        and o.delivered_at is not null
        and t.is_test_team_order = 0
        and o.type like '%119%'
        and o.sigungu = '관악구'
        and o.created_at::date >= '2025-07-29'
        and sector_id in (1,2,3,4,5)
)

, p_log as (
    select distinct user_id, created_at::date as date
    , json_extract_path_text(custom_json,'teamOrderId') as team_order_id
        , json_extract_path_text(custom_json,'routeType') as route_type
    from doeat_data_mart.user_log 
    where created_at::date >='2025-07-29'
    and log_type = '주문 결제'
)


select o.created_at, o.team_order_id, o.user_id, l.route_type
from p_order o
join p_log l on l.team_order_id = o.team_order_id and l.user_id = o.user_id
