select u.user_id as 유저ID
        , u.user_name as 유저명
        , u.user_phone as 전화번호
        , max(l.created_at) over (partition by l.user_id) as last_log_time

from doeat_delivery_production.user u
join (select user_id, created_at from doeat_data_mart.user_log l
    where date(l.created_at) >= '2025-05-16') l
    on u.user_id = l.user_id
