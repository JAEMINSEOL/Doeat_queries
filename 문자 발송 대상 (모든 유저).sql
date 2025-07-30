select distinct u.user_id, u.user_name,ad.hname, ad.address_name,u.gender, u.birth_date, u.user_phone, u.created_at::date as 가입일자, p.is_authorized as 수신동의여부
        , case when p.last_modified_at is null then u.created_at else p.last_modified_at end as 수신동의일
from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on o.team_order_id = t.id
left join doeat_delivery_production.user u on u.user_id = o.user_id
join doeat_delivery_production.user_address ad on u.user_id = ad.user_id
join doeat_delivery_production.user_push_authorization p on u.user_id = p.user_user_id 
                                                                and p.authorization_content_type = 'ADVERTISEMENT' 
                                                                -- and p.is_authorized = 1
where 1
-- and o.orderyn=1
-- and o.paid_at is not null
-- and o.delivered_at is not null
-- and t.is_test_team_order=0
and ad.is_main_address = 1
and ad.hname = '{{행정동}}'
-- and o.created_at::date >= '{{시작날짜}}'
and p.is_authorized = 1
and (ad.address_name like '%집%' or ad.address_name like '%자취방%' or ad.address_name like '%원룸%')
