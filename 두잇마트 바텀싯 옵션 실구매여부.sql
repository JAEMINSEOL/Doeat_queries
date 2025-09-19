with nums AS (  -- 1..N 숫자 생성
  SELECT ROW_NUMBER() OVER () AS n
  FROM svv_columns       -- 아무 뷰나 사용 (충분한 행 수 확보용)
  LIMIT 100
),
params as ( SELECT
                      user_id,
                      main_time,
                      REPLACE(REPLACE(REPLACE(menus, '[',''), ']',''), '"','') AS menus_str
                  FROM (
                      SELECT
                          user_id,
                          l.created_at::timestamp AS main_time,
                          json_extract_path_text(custom_json, 'menuIds') AS menus
                      FROM service_log.user_log l
                      WHERE log_type = '애드온 바텀싯'
                      and log_action = '노출'
                        AND dt >= '{{시작날짜}}'
                    )
                    )

  ,
  params2 as (    SELECT
                     user_id,
                      main_time,
                      REGEXP_REPLACE(
        REGEXP_REPLACE( REGEXP_REPLACE(menus,'[\{\}"]', '' ),  ':[^,}]+' , '' ),'\s+', '') AS menus_str
                  FROM (
                      SELECT
                          user_id,
                          l.created_at::timestamp AS main_time,
                          json_extract_path_text(custom_json, 'menuIds') AS menus
                      FROM service_log.user_log l
                      WHERE log_type = '애드온 바텀싯'
                      and log_action = '노출'
                        AND dt >= '{{시작날짜}}'
                    )
                    )
                    



select l.user_id, l.hour::date as date,l.hour,
p.id as product_id,p.menu_id,p.store_id,
o.sigungu,p.menu_name,n as option_order,
        case when order_id is null then 0 else 1 end as is_ordered
    from(
    select user_id,date_trunc('hour', main_time) as hour,main_time,
            CAST(TRIM(SPLIT_PART(p.menus_str, ',', n::INT)) AS BIGINT) AS menu_id, nums.n
  FROM params p, nums
  WHERE n <= REGEXP_COUNT(p.menus_str, ',') + 1
and NULLIF(TRIM(SPLIT_PART(p.menus_str, ',', n::INT)), '') IS NOT NULL
) l
-- left join(
--     select user_id,date_trunc('hour',main_time) as hour,
--             regexp_substr(menus_str,'[^,]+',1) as menu
--             from (  
--       SELECT
--           user_id,
--           main_time,
--           REPLACE(REPLACE(REPLACE(menus, '{',''), ':1}',''), '"','') AS menus_str
--       FROM (
--       SELECT
--           user_id,
--           l.created_at::timestamp AS main_time,
--           json_extract_path_text(custom_json, 'quantityInfo') AS menus
--       FROM service_log.user_log l
--       WHERE log_type = '애드온 바텀싯'
--       and log_action like '애드온 추가%'
--         AND dt >= '2025-09-17'
--     )
--     )
-- ) l2 on l.user_id=l2.user_id and l.hour=l2.hour
join doeat_delivery_production.doeat_777_product p on p.menu_id = l.menu_id
left join(
        select date_trunc('hour',o.created_at) as hour, o.user_id, p.menu_id,o.id as order_id,o.sigungu
        from doeat_delivery_production.orders o
        join doeat_delivery_production.item i on i.order_id=o.id
        join doeat_delivery_production.doeat_777_product p on p.id=i.product_id
        where o.created_at >= '2025-05-01 00:00'
        ) o on o.hour=l.hour and o.user_id=l.user_id and o.menu_id=l.menu_id
        
        
        
        
