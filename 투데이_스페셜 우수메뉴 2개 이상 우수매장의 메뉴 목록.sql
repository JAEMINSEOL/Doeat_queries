select excellent_product_cnt,a.store_id, store_name
    , product_type, menu_price, a.product_id, menu_name
    , live_sectors, confirmed_sectors_today, confirmed_sectors_tomorrow
from (
    select sp.store_id, product_id, product_type, sp.menu_name, sp.discounted_price as menu_price
         , count(product_id) over (partition by assessment_date, store_id) as excellent_product_cnt
    from doeat_data_mart.mart_store_product sp
    where sp.store_product_type = 'EXCELLENT'
      and sp.assessment_date >= '2025-08-04'
      and sp.product_type in ('DOEAT_777', 'DOEAT_119')
    qualify excellent_product_cnt >= 2
) a
join (
    select id as store_id, store_name, phone_number, president_phone_number 
    from doeat_delivery_production.store
    where is_deleted = 0
      and sigungu in ('관악구', '동작구')
) s on(a.store_id = s.store_id)
join (
    select store_id, listagg(distinct doeat_777_delivery_sector_id, ',') within group (order by doeat_777_delivery_sector_id) as live_sectors
    from doeat_delivery_production.delivery_location a
    join (
        select h.name as hname, s.name as sigungu, h.doeat_777_delivery_sector_id
        from doeat_delivery_production.hdong h
        join doeat_delivery_production.sigungu s on (h.sigungu_id = s.id)
    ) b on (a.hname = b.hname and a.sigungu = b.sigungu)
    where is_deleted = 0
    group by 1
) b on(a.store_id = b.store_id)
left join (
    select product_id
        , listagg(distinct case when date = '2025-08-04' and status = 'CONFIRMED' then sector_id end, ', ') within group (order by sector_id) as confirmed_sectors_today
        , listagg(distinct case when date = '2025-08-05' and status = 'CONFIRMED' then sector_id end, ', ') within group (order by sector_id) as confirmed_sectors_tomorrow
    from doeat_delivery_production.doeat_777_sale_plan_health_check
    where date between '2025-08-04' and '2025-08-05'
    group by 1
) c on(a.product_id = c.product_id)
order by 1,3,4
