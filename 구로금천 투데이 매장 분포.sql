select o.store_id,store_name
            , case when s.category is null then '없음' else s.category end as category
            , s.sigungu
            , h.doeat_777_delivery_sector_id as sector_id
            ,s.hname, s.x,s.y
        -- , count(distinct o.id) as total_ord_cnt
        ,listagg(distinct p.menu_name, ',') as menus
from doeat_delivery_production.store s
    join doeat_delivery_production.doeat_777_product p on p.store_id=s.id
    join doeat_delivery_production.hdong h on h.name = s.hname
    join doeat_delivery_production.orders o on o.store_id = s.id
    join doeat_delivery_production.team_order t on t.id = o.team_order_id
where s.sigungu in ({{시군구}})
    and p.product_type = 'DOEAT_777'
    and o.orderyn=1
    and o.paid_at is not null
    and o.delivered_at is not null
    and t.is_test_team_order=0
group by 1,2,3,4,5,6,7,8
order by s.sigungu, category, sector_id 
