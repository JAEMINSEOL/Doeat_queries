select distinct date(n.created_at) as date, case h.sigungu_id when 1 then '관악구' when 2 then '동작구' when 3 then '구로구' when 4 then '금천구' when 5 then '영등포구' end as sigungu
                ,n.sector_id::text as sector_id, count(distinct p.id) as num_products
                from doeat_delivery_production.doeat_777_product p
                join doeat_delivery_production.doeat_777_noph_metric n on n.product_id=p.id
                join (select sigungu_id, name, doeat_777_delivery_sector_id 
                        from (select *, row_number() over (partition by doeat_777_delivery_sector_id order by created_at desc) as rn
                                from doeat_delivery_production.hdong h )
                        where rn=1) h on h.doeat_777_delivery_sector_id = n.sector_id
WHERE product_type='PB_EVERYDAY' and sub_type='MART'
and (menu_name like '%소금빵%' or menu_name like '%마늘빵%' or menu_name like '%화이트롤%' or menu_name like '%에그타르트%' or menu_name like '%직접 끓인 소고기 미역국%')
and n.created_at>='2025-09-01 00:00'
group by 1,2,3

union all

select distinct date(n.created_at) as date, case h.sigungu_id when 1 then '관악구' when 2 then '동작구' when 3 then '구로구' when 4 then '금천구' when 5 then '영등포구' end as sigungu
                ,'전체' as sector_id, count(distinct p.id) as num_products
                from doeat_delivery_production.doeat_777_product p
                join doeat_delivery_production.doeat_777_noph_metric n on n.product_id=p.id
                join (select sigungu_id, name, doeat_777_delivery_sector_id 
                        from (select *, row_number() over (partition by doeat_777_delivery_sector_id order by created_at desc) as rn
                                from doeat_delivery_production.hdong h )
                        where rn=1) h on h.doeat_777_delivery_sector_id = n.sector_id
WHERE product_type='PB_EVERYDAY' and sub_type='MART'
and (menu_name like '%소금빵%' or menu_name like '%마늘빵%' or menu_name like '%화이트롤%' or menu_name like '%에그타르트%')
and n.created_at>='2025-09-01 00:00'
group by 1,2,3

order by date desc, sigungu,sector_id
