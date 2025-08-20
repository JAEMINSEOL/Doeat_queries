with
opt_base as(
            select s.id as store_id,
                                  s.store_name,
                                  case when s.sigungu in ('구로구','금천구') then '구로금천구' else s.sigungu end as sigungu,
                                  p.id as product_id,
                                  p.menu_name,
                                  m.id as menu_id,
                                  mo.id as option_id,
                                  mo.option_name,
                                  oc.category_name,
                                  m.price,
                                  mo.price as option_price,
                                  mo.is_sold_out,
                                  mo.last_modified_at as last_timestamp
                            from doeat_delivery_production.store s
                                     join doeat_delivery_production.doeat_777_product p on s.id = p.store_id
                                     join doeat_delivery_production.menu m on p.menu_id = m.id
                            join doeat_delivery_production.menu_option_category_mapping moc on moc.menu_id = m.id
                            join doeat_delivery_production.option_category oc on oc.id = moc.option_category_id
                            join (
                                select price, option_category_id, id, is_sold_out, last_modified_at, option_name 
                                from history_schema_v2.menu_option
                                where last_modified_at::date >='2025-05-01' and op != 'D' and is_deleted=0
                            ) mo on moc.option_category_id = mo.option_category_id
                            where p.product_type = 'DOEAT_DESSERT'
                            and p.status = 'AVAILABLE' and m.is_deleted=0 and m.is_hidden=0 and m.is_sold_out=0
                            and oc.required=1
                            -- and (oc.category_name = '선택' or oc.category_name like '%치킨%')
                            and oc.max_selection=1
                            order by s.id
  )
 select distinct slot_time,sigungu
                    -- , last_timestamp, product_id, menu_name, option_id, option_name,is_sold_out
                , count(distinct product_id) as all_menu
                , count(option_id) as all_options
                , count(case when is_sold_out=0 then option_id end) as option_available
                , count(case when is_sold_out=0 then option_id end)*100.0 / count(option_id) as ops_option
                
                from( SELECT *
                    FROM (SELECT
                            t.slot_time,d.product_id, menu_id, option_id, d.sigungu, is_sold_out, last_timestamp,
                            ROW_NUMBER() OVER (
                              PARTITION BY t.slot_time, d.product_id, d.menu_id, d.option_id
                              ORDER BY d.last_timestamp DESC
                            ) AS rn
                          FROM (select dateadd('minute', n * 10, timestamp '2025-08-01 00:00:00') as slot_time
                                         from (select row_number() over () as n
                                                  from doeat_delivery_production.orders o
                                                  limit 10000 )
                                        where DATEADD(minute, n * 10, timestamp '2025-08-01 00:00:00') <= dateadd('hour',9,current_timestamp::timestamp)
                                                  )  t
                          JOIN opt_base d on d.last_timestamp <= t.slot_time
                          join (select distinct created_at, product_id
                                    , case
                                        when sector_id between 1 and 5 then '관악구'
                                        when sector_id between 6 and 10 then '동작구'
                                        when (sector_id between 11 and 14 or sector_id between 20 and 21) then '영등포구'
                                        when sector_id between 15 and 19 then '구로금천구'
                                    end as sigungu
                                  from doeat_delivery_production.doeat_777_noph_metric 
                                  where created_at::date >= '2025-08-01') nph on nph.created_at=t.slot_time and nph.product_id = d.product_id 
                    )
                    WHERE rn = 1
                )

        group by 1,2
        order by 1,2
--   select 
--     e.slot_time,
--     e.product_id,
--     e.menu_id,
--     e.option_id,
--     d.price,
--     d.is_sold_out,
--     d.last_timestamp
--   from (
--         select t.slot_time, c.product_id, c.menu_id, c.option_id
--         from (
--             select distinct product_id, menu_id, option_id
--             from opt_base) c
--         cross join (select dateadd('minute', n * 10, timestamp '2025-08-01 00:00:00') as slot_time
--                      from (select row_number() over () as n
--                               from doeat_delivery_production.orders o
--                               limit 10000 ) 
--           where DATEADD(minute, n * 10, timestamp '2025-08-01 00:00:00') <= current_timestamp) t
--         ) e
--   left join lateral (
--     select d.price, d.is_sold_out, d.last_timestamp
--     from opt_base d
--     where d.product_id = e.product_id
--       and d.menu_id = e.menu_id
--       and d.option_id = e.option_id
--       and d.last_timestamp <= e.slot_time
--     order by d.last_timestamp desc
--     limit 1
--   ) d on true
-- order by product_id, menu_id, option_id, slot_time;
