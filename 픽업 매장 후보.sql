select store_id, store_name, president_phone_number, x, y, distance_bongcheon, distance_seoul_univ
    , sum(order_count) as order_count
    , listagg(product_type, ',') as product_types
    , listagg(menu_name, '//') as curation_menus
from (
    select o.store_id, s.store_name, s.president_phone_number,s.x,s.y
        , 6371 *acos(
            cos(radians(37.48245093567437)) * cos(radians(s.x)) *  
            cos(radians(s.y) - radians(126.94177529849614)) + 
            sin(radians(37.48245093567437)) * sin(radians(s.x))
            )*1000 AS distance_bongcheon --봉천역으로부터 거리
        , 6371 *acos(
            cos(radians(37.481252982489906)) * cos(radians(s.x)) *  
            cos(radians(s.y) - radians(126.95273752581924)) + 
            sin(radians(37.481252982489906)) * sin(radians(s.x))
            )*1000 AS distance_seoul_univ --서울대입구역으로부터 거리
        , p.product_type
        , p.menu_name
        , count(distinct o.id)*1.0/count(distinct date(o.created_at)) as order_count
    from doeat_delivery_production.orders o
    join doeat_delivery_production.user u on o.user_id = u.user_id
    join doeat_delivery_production.team_order t on t.id = o.team_order_id
    join doeat_delivery_production.item i on i.order_id = o.id
    join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
    join doeat_delivery_production.store s on o.store_id = s.id
    where o.orderyn=1
      and o.paid_at is not null
      and o.delivered_at is not null
      and t.is_test_team_order=0
      and p.product_type in ('DOEAT_777')
      and (o.created_at::date between '2025-09-13' and '2025-10-13')
      and u.authority = 'GENERAL'
      and s.sigungu = '관악구'
      and (distance_bongcheon <=400 or distance_seoul_univ <= 400)
    group by 1,2,3,4,5,6,7,8,9) a
group by 1,2,3,4,5,6,7
having sum(order_count) >= 50
order by 8 desc



