with base as (select o.id as order_id, o.created_at, o.sigungu, o.user_id
        , case when o.type like '%SEVEN%' then 'Today' when o.type like '%119%' then 'Special' when o.type='TEAMORDER' then '일반두잇' else 'other' end as type
     -- , h.doeat_777_delivery_sector_id as sector_id
     , sum(case when coalesce(mc.is_alcoholic,0)=1 then item_price end) over (partition by order_id) as alcohol_price
     , sum(case when coalesce(mc.is_alcoholic,0)=0 then item_price end) over (partition by order_id) as non_alcohol_price
        , max(coalesce(mc.is_alcoholic,0)) over (partition by order_id) as ord_alc
        , listagg(case when coalesce(mc.is_alcoholic,0)=1 then menu_name end, ',') over (partition by order_id) as alcohol_name
        , listagg(case when coalesce(mc.is_alcoholic,0)=0 then menu_name end, ',') over (partition by order_id) as non_alcohol_name
from doeat_delivery_production.orders o
    join doeat_delivery_production.team_order t on o.team_order_id = t.id
    join doeat_delivery_production.item i on i.order_id = o.id
    join doeat_delivery_production.menu m on m.id = i.menu_id
    join doeat_delivery_production.menu_category mc on mc.id = m.menu_category_id
    -- join (select *, case sigungu_id when 1 then '관악구' when 2 then '동작구' end as sigungu
    --       from doeat_delivery_production.hdong) h on h.sigungu=o.sigungu and h.name = o.hname
    join doeat_delivery_production.store s on s.id = o.store_id
where o.orderyn = 1
    and o.paid_at is not null
    and o.delivered_at is not null
    and t.is_test_team_order = 0
    and  (type like '%SEVEN%' or type like '%119%' or type ='TEAMORDER')
                                            -- 스페셜 or 일반두잇 or 투데이 주문건수만 필터
    and dateadd('hour',-2,o.created_at)::date between '{{시작날짜}}' and '{{종료날짜}}' --새벽 2시까지 필터
    and extract(hour from o.created_at) >= 8
    -- and mc.is_alcoholic=1
    -- and o.sigungu = '동작구'
    -- and sector_id between 1 and 10
-- group by 1,2,3,4

)
select distinct * from base
where ord_alc=1
order by created_at desc
