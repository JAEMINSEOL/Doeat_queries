select *
from doeat_data_mart.kpi_membership
where start_date >= '2025-01-01'
  and period = '주-월일'
order by 1,4
