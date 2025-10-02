select u.user_id, u.user_name, u.user_phone, u.created_at::date as join_date
     , u.gender, u.birth_date
    ,ps.last_modified_at as servey_time,ps.pmf_score, ps.main_benefit,ps.use_situation
from doeat_delivery_production.user u
join doeat_delivery_production.pmfsurvey ps on ps.user_id = u.user_id
where ps.main_benefit = '이웃과 같이 이용하는 재미'
and u.created_at >= '2025-01-01 00:00'
order by u.created_at desc
-- limit 100
