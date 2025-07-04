SELECT 
        hackle_value,
        f.created_at,
       p.menu_name,
       comment,
       feedback_type
from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on(o.team_order_id = t.id)
join doeat_delivery_production.item i on(o.id = i.order_id)
join doeat_delivery_production.doeat_777_product p on(i.product_id = p.id)
join doeat_delivery_production.curation_feedback f on o.id = f.order_id
join doeat_delivery_production.user_hackle h on h.user_id = o.user_id
where o.orderyn = 1
  and t.is_test_team_order = 0
  and o.paid_at is not null
  and o.delivered_at is not null
  and f.created_at >= '2025-07-04 15:00:00'
  and type = 'CURATION_PB'
  and feedback_type = 'DISLIKE'
  and exp_name = '{{실험명}}'
order by 1,2
