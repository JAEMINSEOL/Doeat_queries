with p_store as(
            select s.id as store_id, s.store_name,s.sigungu
     ,h.name, h.doeat_777_delivery_sector_id as sector_id
     , mc.id, mc.category_name, coalesce(mc.is_alcoholic,0) as is_alcoholic
    , m.id, m.menu_name, m.is_hidden,m.price
    from (select *, case s.sigungu when '관악구' then 1 when '동작구' then 2 end as sigungu_id from doeat_delivery_production.store s) s
    join doeat_delivery_production.menu_category mc on mc.store_id = s.id
    join doeat_delivery_production.menu m on m.menu_category_id = mc.id
    join doeat_delivery_production.hdong h on h.name = s.hname and h.sigungu_id = s.sigungu_id
    join (select distinct store_id from doeat_delivery_production.orders 
                                    where 1 
                                    and created_at >= dateadd('month',-1,current_date)
                                    and orderyn=1 and paid_at is not null and delivered_at is not null) o on o.store_id = s.id    -- 최근 한 달 내 주문이 발생한 매장만 필터
    join (select distinct store_id from doeat_delivery_production.doeat_777_product
                                    where product_type = 'DOEAT_119'
                                    ) p on p.store_id = s.id    -- 스페셜 매장만 필터
    where m.is_deleted=0 and mc.is_deleted=0
        and s.is_deleted=0 and s.is_hidden=0
)


select * from p_store
where is_alcoholic=1 and sector_id={{섹터ID}}
