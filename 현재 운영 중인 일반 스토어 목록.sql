select s.id as store_id, s.store_name, s.contract_status, s.open_time, s.phone_number as "매장전화", s.president_phone_number as "사장님전화"
     , store_order_count,store_review_count, store_avg_point
from doeat_delivery_production.store s
left join doeat_delivery_production.doeat_777_product p on p.store_id=s.id
left join (select distinct store_id, store_type from doeat_data_mart.mart_store_product m) m on m.store_id = s.id
where p.id is null
and s.contract_status = 'ACTIVE'
and s.is_deleted =0
and store_type is null
order by store_type desc
