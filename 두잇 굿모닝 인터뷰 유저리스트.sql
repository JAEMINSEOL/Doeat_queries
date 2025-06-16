select
    u.user_phone
    , u.user_id
    , u.user_name
    , u.gender
    , u.birth_date
    , p.menu_name as 메뉴명
from doeat_delivery_production.orders o
join doeat_delivery_production.user u on u.user_id = o.user_id
join doeat_delivery_production.team_order t on t.id = o.team_order_id
join doeat_delivery_production.item i on i.order_id = o.id
join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
where o.delivered_at is not null
    and o.orderyn = 1
    and t.is_test_team_order = 0
    and o.paid_at is not null
    and o.type = 'DOEAT_MORNING'
    and date(o.created_at) >= '2025-06-14'
