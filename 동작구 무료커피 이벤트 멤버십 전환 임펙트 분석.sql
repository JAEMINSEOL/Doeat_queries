
select distinct u.user_id, ad.sigungu
, isnull(p.use_promo, '미발급') ||'-'|| isnull(p.use_promo, '미사용') as 이벤트_커피_사용
, isnull(a_status, '미가입자')  as 이벤트_전
, isnull(b_status, '미가입자') as 이벤트_후
, 이벤트_전 ||'-'|| 이벤트_후 as 이벤트_전_후
, isnull(c_status, '미가입자') as 이주_뒤

      
from doeat_delivery_production.user u

join doeat_delivery_production.user_address ad on(u.user_id = ad.user_id)
  and sigungu in ('동작구')
left join (select user_id, user_type as a_status from doeat_data_mart.mart_membership where date = '2025-05-16') a on u.user_id = a.user_id
left join (select user_id, user_type as b_status from doeat_data_mart.mart_membership where date = '2025-05-19') b on u.user_id = b.user_id
left join (select user_id, user_type as c_status from doeat_data_mart.mart_membership where date = '2025-06-03') c on u.user_id = c.user_id
left join(select user_id,'사용' as use_promo from doeat_data_mart.user_log
            where log_type = 'FreePBCoffeeDongjakOpenAlert' and log_action = '결제하기 완료'  and date(created_at) >= '2025-05-17'
            ) p on u.user_id = p.user_id
left join(select user_id,'발급' as get_promo from doeat_data_mart.user_log
            where log_type = 'FreePBCoffeeDongjakOpenAlert' and log_action = '이벤트 배너 노출'  and date(created_at) >= '2025-05-17'
            ) g on u.user_id = g.user_id
where u.authority = 'GENERAL'
