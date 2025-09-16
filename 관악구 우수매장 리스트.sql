select distinct m.sigungu,m.store_id,m.store_name,p.product_type,m.contract_status,m.store_type,s.phone_number,s.president_phone_number,s.hname,s.address
from doeat_data_mart.mart_store_product m
join doeat_delivery_production.doeat_777_product p on p.id = m.product_id
join doeat_delivery_production.store s on s.id = p.store_id
where assessment_date='{{날짜}}'
and store_product_type = 'EXCELLENT'
and p.product_type in ({{카테고리}})
and m.sigungu=({{시군구}})
