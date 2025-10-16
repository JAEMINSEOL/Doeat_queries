select s.sigungu, s.id as store_id, s.store_name, p.id as product_id, p.product_type, p.discounted_price, p.category, p.food_category, pc.category_name, p.menu_name, p.qualification_type, product_keyword, last_ordered_at
from doeat_delivery_production.doeat_777_product p
join doeat_delivery_production.store s on s.id = p.store_id
join doeat_delivery_production.product_category_mapping pcm on pcm.doeat_777_product_id = p.id
join doeat_delivery_production.product_category pc on(pcm.category_id = pc.id)
join (select o.store_id, max(o.created_at) as last_ordered_at
        from doeat_delivery_production.orders o
            join doeat_delivery_production.team_order t on o.team_order_id = t.id
        where orderyn=1
            and o.paid_at is not null
            and o.delivered_at is not null
            and t.is_test_team_order=0
        group by 1
        ) o on o.store_id = p.store_id
where p.status = 'AVAILABLE'
and s.contract_status = 'ACTIVE'
and product_type in ('DOEAT_777','DOEAT_119')
and discounted_price = 9900
and s.company_code != 'TESTER' and s.is_fake=0
and p.is_deleted=0
and s.sigungu = '동작구'
order by store_id, product_id
