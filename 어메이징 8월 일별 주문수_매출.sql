select o.created_at::date as date, menu_name
, count(distinct o.id) as "주문수",sum(quantity) as "판매 상품 수" , sum(item_price*quantity) as "매출액(원)"
from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on t.id = o.team_order_id
join doeat_delivery_production.item i on i.order_id = o.id
join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
where o.type = 'CURATION_PB'
and o.orderyn=1
and o.paid_at is not null
and o.delivered_at is not null
and t.is_test_team_order=0
and o.created_at::date>='2025-08-01'
group by 1,2
order by date desc
