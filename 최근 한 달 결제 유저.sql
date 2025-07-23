select distinct u.user_id, u.user_name,o.hname, u.gender, u.birth_date, u.user_phone
from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on o.team_order_id = t.id
join doeat_delivery_production.user u on u.user_id = o.user_id
where o.orderyn=1
and o.paid_at is not null
and o.delivered_at is not null
and t.is_test_team_order=0
and o.hname = '신림동'
and o.created_at::date >= '2025-06-23'
