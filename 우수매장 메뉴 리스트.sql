select distinct m.sigungu,m.store_id,m.store_name,sm.product_id,menu_id,menu_name,price,store_product_type,ord_cnt
from (select distinct m.sigungu,m.store_id,m.store_name from doeat_data_mart.mart_store_product m 
        where assessment_date='{{날짜}}' and store_type = 'EXCELLENT' and product_type in ({{카테고리}}) and m.sigungu=({{시군구}})) m
join (select distinct o.store_id,i.menu_id,m.menu_name,i.product_id,m.price, count(distinct o.id) as ord_cnt
        from doeat_delivery_production.orders o
        join doeat_delivery_production.item i on i.order_id=o.id
        join doeat_delivery_production.menu m on m.id = i.menu_id
        left join doeat_delivery_production.doeat_777_product p on p.id=i.product_id
        where m.is_deleted=0 and m.is_hidden=0
        group by 1,2,3,4,5
        ) sm on sm.store_id=m.store_id
-- join doeat_delivery_production.store s on s.id = p.store_id
left join (select distinct i.product_id,store_product_type from doeat_data_mart.mart_store_product s
join doeat_delivery_production.item i on i.product_id=s.product_id
join doeat_delivery_production.menu m on m.id=i.menu_id
where assessment_date='{{날짜}}'
and m.is_deleted=0 and m.is_hidden=0) p on p.product_id = sm.product_id

order by store_id, sm.product_id,store_product_type,menu_id
