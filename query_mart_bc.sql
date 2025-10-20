with date_range as (
    select distinct operation_date as date
    from doeat_data_mart.mart_date_timeslot_general 
    where operation_date >= '2025-01-01'
),

-- 진입 사용자 데이터 (미리 필터링 및 집계)
enter_users as (
    select 
        mt.operation_date as date,
        case when ua.sigungu in ('구로구', '금천구') then '구로금천구' else ua.sigungu end as sigungu,
        count(distinct ul.user_id) as user_cnt_enter
    from service_log.user_log ul
    join doeat_delivery_production.user_address ua on ul.user_id = ua.user_id
    join doeat_delivery_production.hdong h on ua.hname = h.name
    join doeat_data_mart.mart_date_timeslot_general mt on ul.dt = mt.date and extract(hour from ul.created_at::timestamp) = mt.hour
    where ul.dt >= '2025-01-01'
      and ua.is_main_address = 1 
      and ua.sigungu in ('관악구', '동작구', '영등포구', '구로구', '금천구')
      and h.sigungu_id in (1,2,3,4,5)
      and mt.operation_date >= '2025-01-01'
    group by 1, 2
),

-- 주별 진입 사용자 데이터 (월-일)
weekly_enter_users_mon_sun as (
    select 
        date_trunc('week', mt.operation_date) as start_date,
        case when ua.sigungu in ('구로구', '금천구') then '구로금천구' else ua.sigungu end as sigungu,
        count(distinct ul.user_id) as user_cnt_enter
    from service_log.user_log ul
    join doeat_delivery_production.user_address ua on ul.user_id = ua.user_id
    join doeat_delivery_production.hdong h on ua.hname = h.name
    join doeat_data_mart.mart_date_timeslot_general mt on ul.dt = mt.date and extract(hour from ul.created_at::timestamp) = mt.hour
    where ul.dt >= '2025-01-01'
      and ua.is_main_address = 1 
      and ua.sigungu in ('관악구', '동작구', '영등포구', '구로구', '금천구')
      and h.sigungu_id in (1,2,3,4,5)
      and mt.operation_date >= '2025-01-01'
    group by 1, 2
),

-- 주별 진입 사용자 데이터 (금-목)
weekly_enter_users_fri_thu as (
    select 
        date(dateadd(day, -(extract(dayofweek from date) + 2) % 7, date)) as start_date,
        case when ua.sigungu in ('구로구', '금천구') then '구로금천구' else ua.sigungu end as sigungu,
        count(distinct ul.user_id) as user_cnt_enter
    from service_log.user_log ul
    join doeat_delivery_production.user_address ua on ul.user_id = ua.user_id
    join doeat_delivery_production.hdong h on ua.hname = h.name
    join doeat_data_mart.mart_date_timeslot_general mt on ul.dt = mt.date and extract(hour from ul.created_at::timestamp) = mt.hour
    where ul.dt >= '2025-01-01'
      and ua.is_main_address = 1 
      and ua.sigungu in ('관악구', '동작구', '영등포구', '구로구', '금천구')
      and h.sigungu_id in (1,2,3,4,5)
      and mt.operation_date >= '2025-01-01'
    group by 1, 2
),

-- 주문 사용자 데이터 (미리 필터링 및 집계)
order_users as (
    select 
        mt.operation_date as date,
        case when o.sigungu in ('구로구', '금천구') then '구로금천구' else o.sigungu end as sigungu,
        count(distinct o.user_id) as user_cnt_order,
        count(distinct case when o.type like '%SEVEN%' then o.user_id end) as user_cnt_order_3p_777,
        count(distinct case when o.type like '%119%' then o.user_id end) as user_cnt_order_3p_119,
        count(distinct case when o.type like '%GREEN%' then o.user_id end) as user_cnt_order_3p_green,
        count(distinct case when o.type = 'DOEAT_DESSERT' and extract(hour from o.created_at) in (13,14,15,16,20,21,22,23,0) then o.user_id end) as user_cnt_order_3p_dessert,
        count(distinct case when o.type = 'CURATION_PB' then o.user_id end) as user_cnt_order_1p,
        count(distinct case when o.type = 'TEAMORDER' then o.user_id end) as user_cnt_order_3p_general,
        count(distinct case when o.type not in ('TEAMORDER', 'CURATION_PB') then o.user_id end) as user_cnt_order_3p_curation,
        count(distinct case when o.type = 'DOEAT_CHICKEN' then o.user_id end) as user_cnt_order_3p_chicken,
        count(distinct case when o.type = 'DOEAT_MORNING' then o.user_id end) as user_cnt_order_3p_morning,
        count(distinct case when o.type = 'DOEAT_CHOICE' then o.user_id end) as user_cnt_order_3p_choice
        
    from doeat_delivery_production.orders o
    join doeat_delivery_production.team_order t on o.team_order_id = t.id
    join doeat_data_mart.mart_date_timeslot_general mt on date(o.created_at) = mt.date and extract(hour from o.created_at) = mt.hour
    where mt.operation_date >= '2025-01-01'
      and o.sigungu in ('관악구', '동작구', '영등포구', '구로구', '금천구')
      and o.delivered_at is not null
      and t.is_test_team_order = 0
      and o.paid_at is not null
      and o.orderyn = 1
    group by 1, 2
),

-- 일별 통합 데이터
daily_base as (
    select
        coalesce(e.date, o.date) as date,
        coalesce(e.sigungu, o.sigungu) as sigungu,
        coalesce(e.user_cnt_enter, 0) as user_cnt_enter,
        coalesce(o.user_cnt_order, 0) as user_cnt_order,
        coalesce(o.user_cnt_order_3p_777, 0) as user_cnt_order_3p_777,
        coalesce(o.user_cnt_order_3p_119, 0) as user_cnt_order_3p_119,
        coalesce(o.user_cnt_order_3p_green, 0) as user_cnt_order_3p_green,
        coalesce(o.user_cnt_order_3p_dessert, 0) as user_cnt_order_3p_dessert,
        coalesce(o.user_cnt_order_1p, 0) as user_cnt_order_1p,
        coalesce(o.user_cnt_order_3p_general, 0) as user_cnt_order_3p_general,
        coalesce(o.user_cnt_order_3p_curation, 0) as user_cnt_order_3p_curation,
        coalesce(o.user_cnt_order_3p_chicken, 0) as user_cnt_order_3p_chicken,
        coalesce(o.user_cnt_order_3p_morning, 0) as user_cnt_order_3p_morning,
        coalesce(o.user_cnt_order_3p_choice, 0) as user_cnt_order_3p_choice

    from enter_users e
    full outer join order_users o on e.date = o.date and e.sigungu = o.sigungu
),

-- 주차 계산 (한 번만 계산)
daily_with_weeks as (
    select *,
        -- 금목 주차
        date(dateadd(day, -(extract(dayofweek from date) + 2) % 7, date)) as week_start_fri,
        date(dateadd(day, -(extract(dayofweek from date) + 2) % 7, date)) + interval '6 days' as week_end_fri,
        -- 월일 주차
        date(dateadd(day, -(extract(dayofweek from date) + 6) % 7, date)) as week_start_mon,
        date(dateadd(day, -(extract(dayofweek from date) + 6) % 7, date)) + interval '6 days' as week_end_mon
    from daily_base
),

-- 최종 결과 (UNION ALL 없이 한 번에 처리)
final_result as (
    -- 일별 데이터
    select
        date as start_date,
        date as end_date,
        '일'::VARCHAR as period,
        sigungu::VARCHAR,
        user_cnt_enter,
        user_cnt_order,
        user_cnt_order_3p_777,
        user_cnt_order_3p_119,
        user_cnt_order_3p_green,
        user_cnt_order_3p_dessert,
        user_cnt_order_1p,
        user_cnt_order_3p_general,
        user_cnt_order_3p_curation,
        user_cnt_order_3p_chicken,
        user_cnt_order_3p_morning,
        user_cnt_order_3p_choice,
        user_cnt_order * 100.0 / nullif(user_cnt_enter, 0) as bc,
        user_cnt_order_3p_777 * 100.0 / nullif(user_cnt_enter, 0) as bc_3p_today,
        user_cnt_order_3p_119 * 100.0 / nullif(user_cnt_enter, 0) as bc_3p_special,
        user_cnt_order_3p_green * 100.0 / nullif(user_cnt_enter, 0) as bc_3p_green,
        user_cnt_order_3p_dessert * 100.0 / nullif(user_cnt_enter, 0) as bc_3p_dessert,
        user_cnt_order_1p * 100.0 / nullif(user_cnt_enter, 0) as bc_1p_amazing,
        user_cnt_order_3p_general * 100.0 / nullif(user_cnt_enter, 0) as bc_3p_general,
        user_cnt_order_3p_curation * 100.0 / nullif(user_cnt_enter, 0) as bc_3p_curation,
        user_cnt_order_3p_chicken * 100.0 / nullif(user_cnt_enter, 0) as bc_3p_chicken,
        user_cnt_order_3p_morning * 100.0 / nullif(user_cnt_enter, 0) as bc_3p_morning,
        user_cnt_order_3p_choice * 100.0 / nullif(user_cnt_enter, 0) as bc_3p_choice
    from daily_with_weeks
    
    union all
    
    -- 금목 주차
    select 
        a.start_date,
        a.end_date,
        a.period,
        a.sigungu,
        b.user_cnt_enter,
        a.user_cnt_order,
        a.user_cnt_order_3p_777,
        a.user_cnt_order_3p_119,
        a.user_cnt_order_3p_green,
        a.user_cnt_order_3p_dessert,
        a.user_cnt_order_1p,
        a.user_cnt_order_3p_general,
        a.user_cnt_order_3p_curation,
        a.user_cnt_order_3p_chicken,
        a.user_cnt_order_3p_morning,
        a.user_cnt_order_3p_choice,
        a.bc,
        a.bc_3p_today,
        a.bc_3p_special,
        a.bc_3p_green,
        a.bc_3p_dessert,
        a.bc_1p_amazing,
        a.bc_3p_general,
        a.bc_3p_curation,
        a.bc_3p_chicken,
        a.bc_3p_morning,
        a.bc_3p_choice
    from (
        select
            week_start_fri as start_date,
            week_end_fri as end_date,
            '주-금목'::VARCHAR as period,
            sigungu::VARCHAR,

            -- sum(user_cnt_enter) as user_cnt_enter,
            sum(user_cnt_order) as user_cnt_order,
            sum(user_cnt_order_3p_777) as user_cnt_order_3p_777,
            sum(user_cnt_order_3p_119) as user_cnt_order_3p_119,
            sum(user_cnt_order_3p_green) as user_cnt_order_3p_green,
            sum(user_cnt_order_3p_dessert) as user_cnt_order_3p_dessert,
            sum(user_cnt_order_1p) as user_cnt_order_1p,
            sum(user_cnt_order_3p_general) as user_cnt_order_3p_general,
            sum(user_cnt_order_3p_curation) as user_cnt_order_3p_curation,
            sum(user_cnt_order_3p_chicken) as user_cnt_order_3p_chicken,
            sum(user_cnt_order_3p_morning) as user_cnt_order_3p_morning,
            sum(user_cnt_order_3p_choice) as user_cnt_order_3p_choice,

            sum(user_cnt_order) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc,
            sum(user_cnt_order_3p_777) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_today,
            sum(user_cnt_order_3p_119) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_special,
            sum(user_cnt_order_3p_green) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_green,
            sum(user_cnt_order_3p_dessert) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_dessert,
            sum(user_cnt_order_1p) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_1p_amazing,
            sum(user_cnt_order_3p_general) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_general,
            sum(user_cnt_order_3p_curation) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_curation,
            sum(user_cnt_order_3p_chicken) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_chicken,
            sum(user_cnt_order_3p_morning) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_morning,
            sum(user_cnt_order_3p_choice) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_choice

        from daily_with_weeks
        group by 1, 2, 3, 4
    ) a
    join weekly_enter_users_fri_thu b on(a.start_date = b.start_date and a.sigungu = b.sigungu)
        
    union all
    
    -- 월일 주차
    select
        a.start_date,
        a.end_date,
        a.period,
        a.sigungu,
        b.user_cnt_enter,
        a.user_cnt_order,
        a.user_cnt_order_3p_777,
        a.user_cnt_order_3p_119,
        a.user_cnt_order_3p_green,
        a.user_cnt_order_3p_dessert,
        a.user_cnt_order_1p,
        a.user_cnt_order_3p_general,
        a.user_cnt_order_3p_curation,
        a.user_cnt_order_3p_chicken,
        a.user_cnt_order_3p_morning,
        a.user_cnt_order_3p_choice,
        a.bc,
        a.bc_3p_today,
        a.bc_3p_special,
        a.bc_3p_green,
        a.bc_3p_dessert,
        a.bc_1p_amazing,
        a.bc_3p_general,
        a.bc_3p_curation,
        a.bc_3p_chicken,
        a.bc_3p_morning,
        a.bc_3p_choice
    from (
        select
            week_start_mon as start_date,
            week_end_mon as end_date,
            '주-월일'::VARCHAR as period,
            sigungu::VARCHAR,

            -- sum(user_cnt_enter) as user_cnt_enter,
            sum(user_cnt_order) as user_cnt_order,
            sum(user_cnt_order_3p_777) as user_cnt_order_3p_777,
            sum(user_cnt_order_3p_119) as user_cnt_order_3p_119,
            sum(user_cnt_order_3p_green) as user_cnt_order_3p_green,
            sum(user_cnt_order_3p_dessert) as user_cnt_order_3p_dessert,
            sum(user_cnt_order_1p) as user_cnt_order_1p,
            sum(user_cnt_order_3p_general) as user_cnt_order_3p_general,
            sum(user_cnt_order_3p_curation) as user_cnt_order_3p_curation,
            sum(user_cnt_order_3p_chicken) as user_cnt_order_3p_chicken,
            sum(user_cnt_order_3p_morning) as user_cnt_order_3p_morning,
            sum(user_cnt_order_3p_choice) as user_cnt_order_3p_choice,

            sum(user_cnt_order) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc,
            sum(user_cnt_order_3p_777) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_today,
            sum(user_cnt_order_3p_119) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_special,
            sum(user_cnt_order_3p_green) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_green,
            sum(user_cnt_order_3p_dessert) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_dessert,
            sum(user_cnt_order_1p) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_1p_amazing,
            sum(user_cnt_order_3p_general) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_general,
            sum(user_cnt_order_3p_curation) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_curation,
            sum(user_cnt_order_3p_chicken) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_chicken,
            sum(user_cnt_order_3p_morning) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_morning,
            sum(user_cnt_order_3p_choice) * 100.0 / nullif(sum(user_cnt_enter), 0) as bc_3p_choice       
        from daily_with_weeks
        group by 1, 2, 3, 4
    ) a
    join weekly_enter_users_mon_sun b on(a.start_date = b.start_date and a.sigungu = b.sigungu)
)

select
    start_date,
    end_date,
    period,
    sigungu,

    user_cnt_enter,
    user_cnt_order,
    user_cnt_order_3p_777,
    user_cnt_order_3p_119,
    user_cnt_order_3p_green,
    user_cnt_order_3p_dessert,
    user_cnt_order_1p,
    user_cnt_order_3p_general,
    user_cnt_order_3p_curation,
    user_cnt_order_3p_chicken,
    user_cnt_order_3p_morning,
    user_cnt_order_3p_choice,

    bc,
    bc_3p_today,
    bc_3p_special,
    bc_3p_green,
    bc_3p_dessert,
    bc_1p_amazing,
    bc_3p_general,
    bc_3p_curation,
    bc_3p_chicken,
    bc_3p_morning,
    bc_3p_choice
from final_result
order by start_date desc, period desc, sigungu desc;
