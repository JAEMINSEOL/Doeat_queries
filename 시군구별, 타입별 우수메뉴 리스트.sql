
select 
    q.target_date,  
    s.sigungu,
    sis.shop_in_shop_id,
    
    p.store_id, 
    s.store_name, 
    q.product_id,
    p.menu_name,
    p.product_type, 
    n.sectors,
    n.exposure_min_daily,
    q.average_noph, 
    q.feedback_count,
    q.like_ratio,
    mp.store_product_type, mp.prev_store_product_type ,mp.next_store_product_type ,
    coalesce(mp.excellent_product_count,0) as excellent_product_count

from doeat_delivery_production.curation_product_qualification_log q 
left join doeat_delivery_production.doeat_777_product p on q.product_id = p.id
left join doeat_delivery_production.store s on p.store_id = s.id
left join (
            select distinct product_id, store_id, shop_in_shop_id, excellent_product_count,target_date,store_product_type,prev_store_product_type,next_store_product_type
            from doeat_data_mart.mart_store_product
            -- where target_date = (select max(target_date) from doeat_data_mart.mart_store_product_daily)
            ) mp 
    on q.product_id = mp.product_id and p.store_id = mp.store_id and mp.target_date = q.target_date
left join (
            select 
                date(a.created_at) as date,
                a.product_id,
                count(created_at || sector_id) as exposure_min_daily,
                listagg(distinct sector_id, ',') within group (order by sector_id) as sectors
            from doeat_delivery_production.doeat_777_noph_metric a
            group by 1, 2) n 
    on q.product_id = n.product_id and q.target_date = n.date
left join doeat_delivery_production.shop_in_shop_mapping sis on sis.store_id = p.store_id
where mp.store_product_type = 'EXCELLENT'
and s.sigungu in ({{sigungu}})
and p.product_type in ({{product_type}})
order by q.target_date desc, after_qualification,p.product_type,q.product_id

