with
base as(select o.id
           , o.created_at
           , o.user_id
           , i.product_id
           , p.menu_name
           , json_extract_path_text(o.log_json, 'storeEnterRouteType') as store_enter_route
           , json_extract_path_text(o.log_json, 'routeType')           as route_type
      from doeat_delivery_production.orders o
               join doeat_delivery_production.item i on i.order_id = o.id
               join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
-- join doeat_delivery_production.hdong h on h.name = o.hname
               join doeat_delivery_production.team_order t on t.id = o.team_order_id
      where 1
        and o.orderyn = 1
        and o.paid_at is not null
        and o.delivered_at is not null
        and t.is_test_team_order = 0
        and i.product_id in
            (3929, 3967, 3968, 5746, 5751, 5967, 6057, 6070, 6093, 6095, 6286, 6326, 6335, 6345, 9263, 9283, 6951, 6952,
             6976, 6993, 7000, 7036, 7037, 7054, 7193, 7293, 7376, 7641, 7681, 7682)
        and o.created_at::date between '2025-08-01' and '2025-08-14')
        
select created_at::date as date
, count(distinct id) as 전체주문수
, count(distinct case when store_enter_route = 'carousel_119' then id end) as 스페셜_캐러셀
, count(distinct case when store_enter_route = 'carousel_dessert' then id end) as 디저트_캐러셀
from base
-- where store_enter_route like '%carousel%'
group by 1
order by 1
