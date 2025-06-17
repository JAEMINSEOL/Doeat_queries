
with
p_order AS(
SELECT 
            o.id AS order_id,
            o.created_at,
            o.hname AS 행정동,
             p.id         AS product_id,
             p.menu_name
             , case when menu_name like '%김밥%' or menu_name like '%닭곰탕%' 
            or menu_name like '%샌드위치%' or menu_name like '%장어덮밥%'
            or menu_name like '%연어 포케%' or menu_name like '%샐러드%'
            -- or menu_name like '%아메리카노%'
            or menu_name like '%그릭 요거트%' 
            then 0 else 1 end as mart_product

      FROM doeat_delivery_production.orders AS o
               JOIN doeat_delivery_production.team_order AS t ON t.id = o.team_order_id
               JOIN doeat_delivery_production.item AS i ON o.id = i.order_id
               JOIN doeat_delivery_production.doeat_777_product AS p ON p.id = i.product_id
               JOIN doeat_delivery_production.user AS u ON o.user_id = u.user_id
               
    WHERE o.delivered_at IS NOT NULL
        AND o.orderyn = 1
        AND t.is_test_team_order = 0
        AND o.paid_at IS NOT NULL
        AND u.gender IS NOT NULL
        AND u.birth_date != 'X'
        AND o.type = 'CURATION_PB'
        AND DATE(o.created_at) BETWEEN '{{주문 집계 기간 시작}}' AND '{{주문 집계 기간 종료}}'
        and t.delivery_type != 'BARO_ARRIVAL'
        
),

add_menu AS (

select p.order_id, a.is_add_on
        , a.overall, p.menu_name as item
from p_order p
join (select
        order_id
        , date(created_at) as date
        , max(mart_product) as 두잇마트제품
        , LISTAGG(menu_name, ' , ') WITHIN GROUP (ORDER BY menu_name) AS overall
        , CASE WHEN COUNT(order_id) >= 2 THEN 'add_on' ELSE 'single' END AS is_add_on
        FROM p_order
        GROUP BY 1,2
        ) a on a.order_id = p.order_id
order by 1
)

-- menu_pair as (
                -- select  main_menu
                -- , add_on
                -- , count(order_id) as items
                -- from (
                select
                        a.order_id, a.overall
                        , a.item as main_menu
                        , case when b.is_add_on='add_on' then b.item else 'no_add_on' end as add_on
                        from add_menu a
                        join add_menu b on a.order_id = b.order_id
                        where (main_menu like '%김밥%' or main_menu like '%닭곰탕%' 
                            or main_menu like '%샌드위치%' or main_menu like '%장어덮밥%'
                            or main_menu like '%연어 포케%' or main_menu like '%샐러드%' or main_menu  like '%그릭 요거트%')
                        and not (add_on like '%김밥%' or add_on like '%닭곰탕%' 
                            or add_on like '%샌드위치%' or add_on like '%장어덮밥%'
                            or add_on like '%연어 포케%' or add_on like '%샐러드%' or add_on like '%그릭 요거트%')
                            
                -- )
                -- group by main_menu, add_on
-- )

