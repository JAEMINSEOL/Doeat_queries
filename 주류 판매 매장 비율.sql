with p_store as(
            select s.id as store_id, s.store_name,s.sigungu
     ,h.name, h.doeat_777_delivery_sector_id as sector_id
     , mc.id, mc.category_name, coalesce(mc.is_alcoholic,0) as is_alcoholic
    , m.id, m.menu_name, m.is_hidden
    from (select *, case s.sigungu when '관악구' then 1 when '동작구' then 2 end as sigungu_id from doeat_delivery_production.store s) s
    join doeat_delivery_production.menu_category mc on mc.store_id = s.id
    join doeat_delivery_production.menu m on m.menu_category_id = mc.id
    join doeat_delivery_production.hdong h on h.name = s.hname and h.sigungu_id = s.sigungu_id
    join (select distinct store_id from doeat_delivery_production.orders 
                                    where created_at >= dateadd('month',-1,current_date)
                                    and orderyn=1 and paid_at is not null and delivered_at is not null) o on o.store_id = s.id    -- 최근 한 달 내 주문이 발생한 매장만 필터
where m.is_deleted=0 and mc.is_deleted=0
    and s.is_deleted=0 and s.is_hidden=0
)
, base as(
select s.store_id, s.store_name, s.sigungu, s.sector_id
        , max(coalesce(is_alcoholic,0)) as sell_alcohol
        
from p_store s
where sector_id between 1 and 10
group by 1,2,3,4
order by sigungu, sector_id, store_id
)

, union_base as(
select sigungu, sector_id::text
        , sector_id::int as sort_key
        , count(distinct store_id) as total_store_cnt
        , count(distinct case sell_alcohol when 1 then store_id end) as alcohol_store_cnt
        , alcohol_store_cnt*100.0/total_store_cnt as alcohol_store_rate
from base
group by 1,2,3

union all

select sigungu, '전체' as sector_id
        , null as sort_key
        , count(distinct store_id) as total_store_cnt
        , count(distinct case sell_alcohol when 1 then store_id end) as alcohol_store_cnt
        , alcohol_store_cnt*100.0/total_store_cnt as alcohol_store_rate
from base
group by 1,2

union all

select '전체' as sigungu, '전체' as sector_id
        , null as sort_key
        , count(distinct store_id) as total_store_cnt
        , count(distinct case sell_alcohol when 1 then store_id end) as alcohol_store_cnt
        , alcohol_store_cnt*100.0/total_store_cnt as alcohol_store_rate
from base
order by sigungu, sort_key
)

select * from union_base
where (('{{시군구}}' != ' ' and sigungu = '{{시군구}}') or ('{{시군구}}' = ' '))
and ((sector_id = '전체') or ('{{섹터}}' = ' '))
