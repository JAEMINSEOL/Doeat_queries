with
p_order as (select o.*, u.user_name, u.user_phone, u.gender, u.birth_date
            from doeat_delivery_production.orders o
            join doeat_delivery_production.team_order t on t.id = o.team_order_id
            join doeat_delivery_production.user u on u.user_id = o.user_id
            join doeat_delivery_production.user_push_authorization p on u.user_id = p.user_user_id 
                                                                and p.authorization_content_type = 'ADVERTISEMENT_TEXT' 
                                                                and p.is_authorized = 1
            where o.orderyn=1
            and o.paid_at is not null
            and o.delivered_at is not null
            and t.is_test_team_order=0
            and o.type = 'DOEAT_DESSERT'
            and u.authority = 'GENERAL'
            )
select o.user_id,o.user_name, o.user_phone::text, o.gender, o.birth_date::text
        , count(distinct case when o.created_at::date >= '2025-08-01' then o.id end) as ord_cnt_aug
        , count(distinct case when o.created_at::date between '2025-07-01' and '2025-07-31' then o.id end) as ord_cnt_jul
from p_order o
group by 1,2,3,4,5
having ord_cnt_aug=0 and ord_cnt_jul>0
