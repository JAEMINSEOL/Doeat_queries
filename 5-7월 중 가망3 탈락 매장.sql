select distinct s1.target_date, s1.store_type as store_type_prev, s2.store_type as store_type_now
        ,shop_in_shop_id,s1.store_id, store_name, phone_number, president_phone_number, s1.product_id,s1.product_type, p.menu_name
        , daily_noph, rolling_average_noph, good_ratio, good_ratio_upper_bound, feedback_count,s1.daily_exposure_minutes,exposure_days_last_7days_store
from (select * 
        from(select *, row_number() over (partition by product_id order by target_date desc) as rn
              from doeat_data_mart.mart_store_product
              where target_date between '2025-05-01' and '2025-07-31'
                and store_type = 'INSUFFICIENT_BUSINESS_HOURS'
                and sigungu in ({{지역}})
                and product_type in ({{타입}})
              ) where rn=1) s1 --과거 매장&메뉴 상태
join (select store_id, product_id, store_type
      from doeat_data_mart.mart_store_product
      where target_date = '2025-08-03') s2 on s1.store_id = s2.store_id and s1.product_id = s2.product_id --현재 매장&메뉴 상태 
join (select id as store_id, phone_number,president_phone_number from doeat_delivery_production.store s) s on s1.store_id = s.store_id --매장 정보
join (select id as product_id, menu_name from doeat_delivery_production.doeat_777_product p) p on p.product_id=s1.product_id --product 정보
where 1
and s2.store_type != 'EXCELLENT'
