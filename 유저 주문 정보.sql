select o.created_at, o.sigungu, o.type,o.order_price, m.menu_name
        , datediff('minute',o.paid_at,o.delivered_at) as delivering_duration, feedback_type, comment
from doeat_delivery_production.orders o
join doeat_delivery_production.item i on i.order_id = o.id
join doeat_delivery_production.menu m on m.id = i.menu_id
left join doeat_delivery_production.curation_feedback fd on fd.order_id = o.id
where o.orderyn=1
and o.delivered_at is not null
and o.paid_at is not null
and o.user_id = {{유저ID}}
order by o.created_at desc
