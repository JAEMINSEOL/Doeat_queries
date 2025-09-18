
            select distinct main_time::date as date
                        ,main_time
                        ,log_action as team_order_id
                        ,user_id
                        ,log_code
                        ,log_type as after_action
                        ,menu_name
            from(
               
                SELECT
                    l.user_id,
                    row_number() over (partition by l.user_id order by l.created_at) as rn,
                    case when l.log_type='주문 결제' then 0 when l.log_type='메인 진입' then 1 when l.log_type='커뮤니티' then 2 else 3 end as log_code,
                    ROW_NUMBER() OVER (PARTITION BY main_time ORDER BY log_code DESC) AS rn2,
                    l.created_at::timestamp,
                    l.log_type,
                    m.log_action,
                    m.main_time,
                    menu_name
                FROM service_log.user_log l
                JOIN (SELECT
                        user_id,
                        l.created_at::timestamp AS main_time,
                        log_type,
                        log_action,log_route,log_route_type,
                        p.menu_name
                    FROM service_log.user_log l
                    join doeat_delivery_production.doeat_777_product p on p.id = l.custom
                    WHERE log_type = '주문 결제'
                    and dt>='{{날짜}}'
                    and log_route_type like '%_everyday'
                    and p.product_type = 'PB_EVERYDAY') m
                  ON l.user_id = m.user_id
                 AND l.created_at::timestamp between dateadd('second',0,m.main_time) and dateadd(minute,{{시간(분)}},m.main_time)
                WHERE l.log_type IN ('주문 결제','메인 진입','스토어 진입', '치킨 키우기','커뮤니티','마이두잇 진입','주문 내역')
            and dt>= '{{날짜}}'
            )
            
            order by main_time,user_id,log_code
