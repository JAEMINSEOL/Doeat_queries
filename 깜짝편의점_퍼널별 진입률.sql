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
                      WHERE log_type = '깜짝편의점'
                      and log_action = '바텀씻 노출'
                        AND dt >= '2025-09-26'
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
                          json_extract_path_text(custom_json, 'quantityInfo') AS menus
                      FROM service_log.user_log l
                      WHERE log_type = '깜짝편의점'
                      and log_action  = '상품 추가'
                        AND dt >= '2025-09-26'
                    )
                    )
                    
select hour, hackle_value
        , count(distinct uid_all) as all_users
        , count(distinct uid_pb) as pb_users
        , count(distinct uid_view) as view_cnt
        , count(case when bottomsheet_click=1 then uid_view end) as click_cnt
        , count(case when is_ordered=1 then uid_view end) as order_cnt
        , view_cnt *100.0 / nullif(pb_users,0) as "CTR"
        , click_cnt *100.0 / nullif(view_cnt,0) as add_to_cart_ratio
        , order_cnt *100.0 / nullif(view_cnt,0) as "CVR"

from(
        select l0.user_id as uid_all,l.user_id as uid_pb, l1.user_id as uid_view,l2.user_id as uid_click,uh.hackle_value, l.hour::date as date,l.hour,
        -- p.id as product_id,p.menu_id,p.store_id,
        -- o.sigungu,p.menu_name,n as option_order,
                case when l2.user_id is null then 0 else 1 end as bottomsheet_click,
                case when order_id is null then 0 else 1 end as is_ordered,
                case when bottomsheet_click=0 and is_ordered=1 then 1 else 0 end as carousel_click
            from doeat_delivery_production.user u 
            join doeat_delivery_production.user_hackle uh on uh.user_id=u.user_id
            left join (select user_id, dt as date, date_trunc('hour', main_time) as hour
                    from (SELECT
                          user_id,dt,
                          l.created_at::timestamp AS main_time
                      FROM service_log.user_log l
                      WHERE 1
                        AND dt >= '2025-09-26')) l0 on l0.user_id = u.user_id 
            left join (select user_id, dt as date, date_trunc('hour', main_time) as hour
                    from (SELECT
                          user_id,dt,
                          l.created_at::timestamp AS main_time
                      FROM service_log.user_log l
                      WHERE log_type = '두잇 Everyday'
                      and log_action like '두잇 에브리데이 결제 페이지 이동%'
                        AND dt >= '2025-09-26')) l on l.user_id = l0.user_id and l.hour = l0.hour 
            
            left join (select user_id, dt as date, date_trunc('hour', main_time) as hour
                    from (SELECT
                          user_id,dt,
                          l.created_at::timestamp AS main_time
                      FROM service_log.user_log l
                      WHERE log_type = ' 깜짝편의점'
                      and log_action = '바텀씻 진입점 클릭'
                        AND dt >= '2025-09-26')
                        ) l1 on l.user_id = l1.user_id and l.hour = l1.hour 
            left join (select user_id, dt as date, date_trunc('hour', main_time) as hour
                    from (SELECT
                          user_id,dt,
                          l.created_at::timestamp AS main_time
                      FROM service_log.user_log l
                      WHERE log_type = ' 깜짝편의점'
                      and log_action = '상품 추가'
                        AND dt >= '2025-09-26')) l2 on l.user_id = l2.user_id and l.hour = l2.hour 
            
            -- left join(
            --         select user_id,date_trunc('hour', main_time) as hour,main_time,
            --                 coalesce(CAST(TRIM(SPLIT_PART(p.menus_str, ',', n::INT)) AS BIGINT),0) AS menu_id, nums.n
            --         FROM params p, nums
            --         WHERE n <= REGEXP_COUNT(p.menus_str, ',') + 1
            --         and NULLIF(TRIM(SPLIT_PART(p.menus_str, ',', n::INT)), '') IS NOT NULL
            --         ) l1 on l1.user_id = l.user_id and l1.hour = l.hour

            -- left join(
            --         select user_id,date_trunc('hour', main_time) as hour,main_time,
            --                 coalesce(CAST(TRIM(SPLIT_PART(p.menus_str, ',', n::INT)) AS BIGINT),0) AS menu_id
            --       FROM params2 p, nums
            --       WHERE n <= REGEXP_COUNT(p.menus_str, ',') + 1
            -- and NULLIF(TRIM(SPLIT_PART(p.menus_str, ',', n::INT)), '') IS NOT NULL
            -- ) l2 on l2.user_id=l1.user_id and l2.hour=l1.hour and l2.menu_id=l1.menu_id

            -- left join doeat_delivery_production.doeat_777_product p on p.menu_id = l1.menu_id
            left join(
                    select date_trunc('hour',o.created_at) as hour, o.user_id, p.menu_id,o.id as order_id,o.sigungu
                    from doeat_delivery_production.orders o
                    join doeat_delivery_production.item i on i.order_id=o.id
                    join doeat_delivery_production.doeat_777_product p on p.id=i.product_id
                    where o.created_at >= '2025-05-01 00:00'
                    and p.product_type = 'PB_EVERYDAY' and p.sub_type = 'MART' and p.id not in (10938,10058,10056,10178,10180,10185,10187,10461,10463)
                    ) o on o.hour=l1.hour and o.user_id=l1.user_id 
                    
            where 1
            -- and u.authority='GENERAL'
            and uh.experiment_id = 3456
    )
group by 1,2
order by 1,2
