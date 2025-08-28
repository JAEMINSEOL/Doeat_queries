select created_at::date, product_type, sigungu, after_qualification_type,count(distinct product_id)
from (
select p.product_type, ms.product_id, p.menu_name, sigungu, qc.*
      from doeat_delivery_production.curation_store_qualification_log qc
               join (select distinct shop_in_shop_id, product_id,store_id from doeat_data_mart.mart_store_product) ms
                    on ms.shop_in_shop_id = qc.shop_in_shop_id
               join (select distinct id, product_type, menu_name from doeat_delivery_production.doeat_777_product) p
                    on ms.product_id = p.id
               join (select id, store_name, sigungu from doeat_delivery_production.store) s on s.id = ms.store_id
      where before_qualification_type = 'EXCELLENT'
        and after_qualification_type != 'EXCELLENT'
        and created_at::date >= '2025-08-27'
        and p.product_type like '%119%'
      order by created_at desc
      )
group by 1,2,3,4
order by 1,3
