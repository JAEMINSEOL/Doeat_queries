select  hour::date as date
        , count(distinct case when app_enter=1 then user_id end) as app_enter_user_cnt
        , count(distinct case when community_enter=1 then user_id end) as community_enter_user_cnt
        , count(distinct case when main_page=1 then user_id end) as moim_main_page_user_cnt
        , count(distinct case when click_moim=1 then user_id end) as moin_chat_click_user_cnt
        , count(distinct case when chat_room_join=1 then user_id end) as chat_room_join_user_cnt
        , count(distinct case when chat_room_create=1 then user_id end) as chat_room_create_user_cnt

from(select
        date_trunc('hour',l.created_at::timestamp) as hour, l.user_id, 
        max(case when log_type like '%라우팅조사%' then 1 end) as app_enter,
        max(case when log_type = '커뮤니티' and log_action = '페이지 진입' then 1 end) as community_enter,
        max(case when log_type = '우리동네 모임' and log_action = '모임 목록 노출' then 1 end) as main_page,
        max(case when log_type = '우리동네 모임' and log_action = '모임 클릭' then 1 end) as click_moim,
        max(case when log_type = '우리동네 모임' and log_action = '모임 대문 진입' then 1 end) as moim_chat_front_page,
        max(case when log_type = '우리동네 모임' and log_action = '모임 참여하기 클릭' then 1 end) as chat_room_join,
        max(case when log_type = '우리동네 모임' and log_action = '모임 만들기 진입' then 1 end) as chat_room_create
        
        -- , count(distinct case when log_type = '다이렉트 채팅' and log_action = '페이지 진입' then l.user_id end) as chat_room_enter_user_cnt2,
        -- count(distinct case when log_type = '다이렉트 채팅' and log_action = '채팅방 클릭' then l.user_id end) as chat_room_enter_user_cnt3,
        -- count(distinct case when log_type = '다이렉트 채팅' and log_action = '메시지 전송 클릭' then l.user_id end) as chat_room_send_message
        -- fortune_enter_user_cnt * 100.0 / piyak_enter_user_cnt as piyak_to_fortune
    from service_log.user_log l
    join doeat_delivery_production.user u on u.user_id = l.user_id
    join doeat_delivery_production.user_address ua on l.user_id = ua.user_id and is_main_address = 1
    join (select distinct name, doeat_777_delivery_sector_id as sector_id from doeat_delivery_production.hdong where sigungu_id = 1 and doeat_777_delivery_sector_id in (1,2,3,4,5)) c on(ua.hname = c.name)
    where dt >= '2025-10-16' 
    and u.authority = 'GENERAL'
    group by 1,2
) l
where hour >= '2025-10-16 11:00'

group by 1
order by 1 desc
