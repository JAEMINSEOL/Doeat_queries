select l.hour, uh.hackle_value
        , count(distinct case when is_enter=1 then u.user_id end) as enter_cnt
        , count(distinct case when has_pay_page=1 then u.user_id end ) as pay_page_cnt
        , count(distinct case when has_pay_page=1 and has_open_bottomsheet=1 then u.user_id end) as bottomsheet_cnt
        ,count(distinct case when has_pay_page=1 then o.user_id end ) as order_cnt
        , count(distinct case when has_pay_page=1 and has_open_bottomsheet=1 then o.user_id end) as bottomsheet_order_cnt
        , order_cnt *100.0 / nullif(enter_cnt,0) as "BC"
        , 100-order_cnt*100.0/nullif(pay_page_cnt,0) as exit_rate
        , 100-bottomsheet_order_cnt*100.0/nullif(bottomsheet_cnt,0) as exit_rate_bottomsheet

from doeat_delivery_production.user u
join (select user_id, hackle_value from doeat_delivery_production.user_hackle uh 
                                    where uh.experiment_id = 3456) uh on uh.user_id=u.user_id

join(
select dt as date, date_trunc('hour', l.created_at::timestamp) as hour, l.user_id 
        , 1 as is_enter
        , max(case when l.log_type = '두잇 Everyday' and l.log_action like '두잇 에브리데이 결제 페이지 이동%' then 1 end) as has_pay_page
        , max(case when l.log_type = '깜짝편의점' and l.log_action = '바텀씻 진입점 클릭' then 1 end) as has_open_bottomsheet
        from service_log.user_log l
        where l.dt >= '2025-09-26'
        group by 1,2,3
        having hour>='2025-09-26 15:00'
) l on l.user_id = u.user_id

left join (
    select date_trunc('hour', o.created_at::timestamp) as hour, o.user_id 
    from doeat_delivery_production.orders o 
    join doeat_delivery_production.team_order t on t.id=o.team_order_id
    where o.orderyn=1
    and o.paid_at is not null
    and o.status not in ('WAIT','CANCEL')
    and t.is_test_team_order=0
    and o.type = 'CURATION_PB') o on o.user_id=l.user_id and o.hour=l.hour
where l.hour is not null
group by 1,2
order by 1,2
