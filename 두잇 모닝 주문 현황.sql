with p_order as (select o.*
                      , i.product_id, i.quantity, p.menu_name
--                  , regexp_substr(log_json, '"menuName"\s*:\s*"([^"]+)"', 1, 1, 'e') ||','|| regexp_substr(log_json, '"menuName"\s*:\s*"([^"]+)"', 1, 2, 'e') as menu
                from (select o.id, o.created_at, o.type, o.user_id, o.status
                      from doeat_delivery_production.orders o
                               join doeat_delivery_production.team_order t on o.team_order_id = t.id
                          and o.orderyn = 1
                          AND o.paid_at IS NOT NULL
                          AND t.is_test_team_order = 0
                          AND date(o.created_at) >= '2025-06-14'
                          and o.status != 'WAIT'
                          and o.type = 'DOEAT_MORNING') o
                left join doeat_delivery_production.item i on i.order_id = o.id
                join doeat_delivery_production.doeat_777_product p on i.product_id = p.id

                     )
,
    p_order_r AS (
    SELECT
        bo1.user_id
        , bo1.created_at
    , bo1. product_id
    , 1 as is_repeated
    FROM p_order bo1
    WHERE EXISTS (
        SELECT 1
        FROM p_order bo2
        WHERE bo2.user_id = bo1.user_id
          AND bo2.created_at::date < bo1.created_at::date
        and bo2.product_id = bo1.product_id
    )
)


select date(o.created_at) as date
       , case when o.status = 'ORDERED' then '주문만_완료(배달X)'
            when o.status = 'CANCEL' then '주문 취소'
            when o.status = 'DELIVERED' then '배달 완료'
            else '기타' end as "주문 상태"
       , count(distinct case when o.product_id = 7991 then o.id end) as "미역국(주문수)"
       , count(distinct case when o.product_id = 7992 then o.id end) as "요거트(주문수)"
        , count(distinct id) as "전체 주문수"
        ,coalesce(sum(case when o.product_id = 7991 then quantity end),0) as "미역국 (수량)"
       , coalesce(sum(case when o.product_id = 7992 then quantity end),0) as "요거트(수량)"
        , sum(quantity) as "전체 주문 수량"
        ,coalesce(sum(case when o.product_id = 7991 then is_repeated end),0) as "미역국 (재주문자)"
       , coalesce(sum(case when o.product_id = 7992 then is_repeated end),0) as "요거트 (재주문자)"

    from p_order o
left join p_order_r r on o.user_id = r.user_id and o.created_at = r.created_at and o.product_id = r.product_id
group by 1,2
order by 1,2
