with 
base as( 
    select f.start_date, extract('dow' from f.start_date) as dow, f.sigungu, f.period, f.gtv_total, u2.transaction_user_cnt, u2.rolling_30d_transaction_user_cnt
    from (
        -- select sigungu, start_date,period, gtv_total
        -- from doeat_data_mart.kpi_finance
        -- where start_date >= '2025-04-01'
        --   and period = '일'
          
        --   union all
          
        select '전체' as sigungu, start_date,period,sum(gtv_total) as gtv_total
        from doeat_data_mart.kpi_finance
        where start_date >= '2025-03-31'
          and period = '일'
          group by 1,2,3
    ) f
    left join (
        select start_date, dateadd(day, 0, start_date) as week, sigungu
            , transaction_user_cnt
            , new_user_cnt
            , resurrect_user_cnt
            , rolling_30d_transaction_user_cnt
            , rolling_30d_new_user_cnt
            , rolling_30d_resurrect_user_cnt
            
        from doeat_data_mart.mart_user_cnt
        where period = '일'
        and sigungu = '전체'
    ) u2 on(u2.week = f.start_date and u2.sigungu = f.sigungu)
    order by start_date desc, sigungu
)

select extract('week' from start_date) as "주", date_trunc('week',start_date)::date as "일자",
            sum(case when dow=1 then gtv_total end) as "월",
            sum(case when dow=2 then gtv_total end) as "화",
            sum(case when dow=3 then gtv_total end) as "수",
            sum(case when dow=4 then gtv_total end) as "목",
            sum(case when dow=5 then gtv_total end) as "금",
            sum(case when dow=6 then gtv_total end) as "토",
            sum(case when dow=0 then gtv_total end) as "일"
from base
group by 1,2
order by "주"
