select 
    s.id as store_id
    , s.hname as 행정동
    , s.store_name as 매장명
    , s.category as 카테고리
    , case when num_orders is null then 1 else 0 end as 미입점
    , case when p.store_id is null then 1 else 0 end as need_to_visit
    -- , count(distinct s.id) as total_store_cnt
    -- , count(distinct case when p.store_id is null then s.id end) as need_to_visit_store_cnt
    
from doeat_delivery_production.store s     
left join doeat_delivery_production.doeat_777_target_store t on t.store_id = s.id
left join (select distinct store_id from doeat_delivery_production.doeat_777_product) p on t.store_id = p.store_id
left join (select o.store_id, count(o.id) as num_orders from doeat_delivery_production.team_order o group by 1) o on o.store_id = s.id
where s.sigungu = '동작구'
    and s.hname not in ('신대방1동','신대방2동','')



-- select count(distinct t.store_id) as total_store_cnt,
--     count(distinct case when p.store_id is null then t.store_id end) as need_to_visit_store_cnt 
-- from doeat_delivery_production.doeat_777_target_store t
-- left join doeat_delivery_production.store s on t.store_id = s.id
-- left join (select distinct store_id from doeat_delivery_production.doeat_777_product) p on t.store_id = p.store_id
-- where s.sigungu = '동작구'
--     and s.hname != '신대방1동'
--     and s.hname != '신대방2동'

-- select distinct s.id, t.store_id, p.store_id
-- from doeat_delivery_production.store s
-- left join doeat_delivery_production.doeat_777_target_store t on s.id = t.store_id
-- left join (select distinct store_id from doeat_delivery_production.doeat_777_product) p on t.store_id = p.store_id
-- where sigungu = '동작구'
--     and p.store_id is null


-- select count(distinct s.id)
-- from doeat_delivery_production.store s
-- where sigungu = '동작구'
--     and hname != '신대방1동'
--     and hname != '신대방2동'

-- 동작구 스토어 954개






-- with s as (select t.store_id,
--                   s.sigungu,
--                   s.hname,
--                   s.store_name
--                       , case when p.created_at is null then 0 else 1 end as is_doeat_777_proceed
--                       ,max(p.created_at) as visited_time
     
--           from doeat_delivery_production.doeat_777_target_store as t

--                     left join doeat_delivery_production.store as s on t.store_id = s.id
-- left join doeat_delivery_production.doeat_777_product as p on t.store_id = p.store_id
--           where s.sigungu = '동작구'
--              and s.hname != '신대방1동'
--              and s.hname != '신대방2동'
             
--              group by 1,2,3,4,5
--           )
--     select
--         sum(is_doeat_777_proceed) as sum_is_doeat_777_proceed
-- , count(store_name) as sum_all
-- from s
