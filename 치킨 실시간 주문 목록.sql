select convert(o.id, char) as order_id,
       o.created_at,
       o.status,
       o.sigungu,
       p.menu_name
from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on(o.team_order_id = t.id)
join (
    select distinct s.name as sigungu, h.name as hname, h.doeat_777_delivery_sector_id as sector_id
    from doeat_delivery_production.hdong h
    join doeat_delivery_production.sigungu s on(h.sigungu_id = s.id)
) h on(o.sigungu = h.sigungu and o.hname = h.hname)
join doeat_delivery_production.item i on (i.order_id = o.id)
join doeat_delivery_production.doeat_777_product p on(p.id = i.product_id)
where o.orderyn = 1
  and t.is_test_team_order = 0
  and o.sigungu in ({{지역}})
  and date(o.created_at) >= '{{시작날짜}}'
  and o.type like '%CHICKEN%'
order by 1 desc
