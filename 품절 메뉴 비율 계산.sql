select created_at as date, sigungu
--         , count(distinct product_id) as "전체메뉴"
        , count(option_id) as "판매가능메뉴"
        , count(case when is_sold_out=0 then option_id end) as "비품절_판매가능메뉴"
        , "비품절_판매가능메뉴"*100.0 / "판매가능메뉴" as "유효옵션 가동률"
from(select *
from (select distinct o.created_at::date from doeat_delivery_production.orders o where o.created_at::date>='2025-08-01') dt
join (select s.id as store_id,
                       s.store_name,
                       case when s.sigungu in ('구로구','금천구') then '구로금천구' else s.sigungu end as sigungu,
                       p.id as product_id,
                       p.menu_name,
                       m.id as menu_id,
                       mo.id as option_id,
                       mo.option_name,
                       m.price,
                       mo.price,
                       mo.is_sold_out,
                       mo.last_modified_at as last_timestamp
                from doeat_delivery_production.store s
                         join doeat_delivery_production.doeat_777_product p on s.id = p.store_id
                         join doeat_delivery_production.menu m on p.menu_id = m.id
                join doeat_delivery_production.menu_option_category_mapping moc on moc.menu_id = m.id
                join (select price, option_category_id, id, is_sold_out, last_modified_at, option_name from history_schema_v2.menu_option) mo on moc.option_category_id = mo.option_category_id
                where p.product_type = 'DOEAT_CHICKEN'
                and p.status = 'AVAILABLE' and m.is_deleted=0 and m.is_hidden=0 and m.is_sold_out=0
                order by store_id) b on 1=1
WHERE b.last_timestamp < dt.created_at
QUALIFY ROW_NUMBER() OVER (PARTITION BY b.option_id, dt.created_at
                        ORDER BY (dt.created_at - b.last_timestamp) ASC,
                         b.last_timestamp DESC ) = 1
)
group by 1,2

-- having "판매가능메뉴" != 0

-- select *
-- from history_schema_v2.menu_option h2 
-- where h2.id=312243940
-- order by created_at
