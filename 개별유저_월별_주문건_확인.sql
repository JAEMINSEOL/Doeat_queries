select
    user_id
    , o.created_at as order_time
     , o.type
     , o.store_id
     , s.store_name

from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on t.id=o.team_order_id
join doeat_delivery_production.store s on s.id=o.store_id

where o.orderyn=1
    and o.delivered_at is not null
    and o.paid_at is not null
    and t.is_test_team_order=0
    and date(o.created_at) > '2025-05-18'
    and user_id = {{유저ID}}
order by 2 desc
