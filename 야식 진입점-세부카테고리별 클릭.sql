with log_data as (
    select operation_date as date,sigungu,
            count(distinct case when 1 then l.user_id end) as click_119_category_all,
           count(distinct case when (json_extract_path_text(custom_json,'categoryName') like '%족발%' ) then l.user_id end) as "족발", "족발" *100.0 / click_119_category_all as 족발_ratio,
           count(distinct case when (json_extract_path_text(custom_json,'categoryName') like '%보쌈%' ) then l.user_id end) as "보쌈", "보쌈" *100.0 / click_119_category_all as 보쌈_ratio,
           count(distinct case when (json_extract_path_text(custom_json,'categoryName') like '%찜/탕%' ) then l.user_id end) as "찜/탕", "찜/탕" *100.0 / click_119_category_all as 찜탕_ratio,
           count(distinct case when (json_extract_path_text(custom_json,'categoryName') like '%육회%' ) then l.user_id end) as "육회", "육회" *100.0 / click_119_category_all as 육회_ratio,
           count(distinct case when ( json_extract_path_text(custom_json,'categoryName') like '%사시미%' ) then l.user_id end) as "회/사시미", "회/사시미" *100.0 / click_119_category_all as 회사시미_ratio,
            count(distinct case when (json_extract_path_text(custom_json,'categoryName') like '%닭발%' ) then l.user_id end) as "닭발/쭈꾸미", "닭발/쭈꾸미" *100.0 / click_119_category_all as 닭발쭈꾸미_ratio,
           count(distinct case when (json_extract_path_text(custom_json,'categoryName') like '%곱창%' ) then l.user_id end) as "곱창", "곱창" *100.0 / click_119_category_all as 곱창_ratio,
           count(distinct case when (json_extract_path_text(custom_json,'categoryName') like '%별미%' ) then l.user_id end) as "별미", "별미" *100.0 / click_119_category_all as 별미_ratio
          

           from service_log.user_log l
           join doeat_data_mart.mart_date_timeslot_general mdt on(date(l.created_at) = mdt.date and date_part(h, l.created_at::timestamp) = mdt.hour)
           join (select u.user_id,sigungu 
                   from doeat_delivery_production.user u
                   join doeat_delivery_production.user_address ad on ad.user_id=u.user_id
                    where ad.is_main_address=1
           ) u on u.user_id = l.user_id
          
    where dt >= '{{시작날짜}}'
    and (log_type = '119-Carousel' and log_action = 'click 119 category')
    and sigungu in ('관악구','동작구','구로구','금천구','영등포구')
    group by 1,2 
    -- having page_enter_user_cnt>0
)


select a.*

from log_data a
where 1
and a.sigungu = '{{시군구}}'
and a.date between '{{시작날짜}}' and current_date
order by date desc
