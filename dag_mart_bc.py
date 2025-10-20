import pendulum
import os
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.hooks.redshift_sql import RedshiftSQLHook
from airflow.models import Variable
from util.slack import slack_failure_notification, send_message

# Import local modules
from data_mart.mart_bc.queries.query_mart_bc import execute_temp_table_merge, validate_date_parameters

# Redshift에 업로드할 테이블 이름
REDSHIFT_TABLE_NAME = 'doeat_data_mart.mart_bc'
# KST timezone for date handling
KST = pendulum.timezone("Asia/Seoul")


def check_table_exists(table_name):
    """Check if the table exists in Redshift"""
    query = f"""
    SELECT EXISTS (
        SELECT 1 
        FROM pg_tables 
        WHERE schemaname = '{table_name.split('.')[0]}' 
        AND tablename = '{table_name.split('.')[1]}'
    );
    """
    hook = RedshiftSQLHook()
    conn = hook.get_conn()
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    return result[0]  # Returns True if table exists, False otherwise


def run_mart_mart_bc(**context):
    """Main function to update mart_bc mart data using temp table approach"""
    # Get start_date and end_date from params if provided
    params = context.get('params', {})
    user_start_date = params.get('start_date')
    user_end_date = params.get('end_date')
    
    # **핵심 수정: logical_date 사용**
    logical_date = context.get('logical_date') or context.get('execution_date')
    if logical_date:
        # logical_date를 KST로 변환하여 사용
        logical_dt = logical_date.in_timezone(KST)
        # **15일 범위: 14일 전부터 당일까지**
        default_end_date = logical_dt.strftime('%Y-%m-%d')  # 당일 데이터
        default_start_date = logical_dt.subtract(days=15).strftime('%Y-%m-%d')  # 15일 범위
    else:
        # fallback으로 오늘 기준
        today_kst = datetime.now(KST).replace(hour=0, minute=0, second=0, microsecond=0)
        default_end_date = today_kst.strftime('%Y-%m-%d')
        default_start_date = (today_kst - pendulum.duration(days=15)).strftime('%Y-%m-%d') 
    
    # start_date 처리
    if user_start_date:
        try:
            # Parse the provided start_date
            clean_date = user_start_date.strip().strip('"').strip("'")
            start_dt = pendulum.parse(clean_date, tz=KST)
            start_date = start_dt.to_date_string()
            print(f"Using provided start_date: {start_date}")
        except Exception as e:
            print(f"Invalid start_date format: {user_start_date}. Using default start_date.")
            start_date = default_start_date
    else:
        # **핵심 변경: 15일 전 사용**
        start_date = default_start_date
        print(f"No start_date provided. Using default start_date (15 days range): {start_date}")
    
    # end_date 처리
    if user_end_date:
        try:
            clean_date = user_end_date.strip().strip('"').strip("'")
            end_dt = pendulum.parse(clean_date, tz=KST)
            end_date = end_dt.to_date_string()
            print(f"Using provided end_date: {end_date}")
        except Exception as e:
            print(f"Invalid end_date format: {user_end_date}. Using default end_date.")
            end_date = default_end_date
    else:
        # **핵심 변경: 당일 데이터 사용**
        end_date = default_end_date
        print(f"No end_date provided. Using default end_date (today): {end_date}")
    
    print(f"Processing mart_bc data from {start_date} to {end_date}")
    
    # Check if the target table exists
    table_exists = check_table_exists(REDSHIFT_TABLE_NAME)
    
    # Execute the temp table merge process
    execute_temp_table_merge(start_date, end_date, table_exists)
    
    print("mart_bc update completed successfully")


def validate_params(**context):
    """Validate DAG parameters before execution"""
    params = context.get('params', {})
    user_start_date = params.get('start_date')
    user_end_date = params.get('end_date')
    
    # logical_date 가져오기
    logical_date = context.get('logical_date') or context.get('execution_date')
    if logical_date:
        logical_dt = logical_date.in_timezone(KST)
        default_end_date = logical_dt.strftime('%Y-%m-%d')
        default_start_date = logical_dt.subtract(days=14).strftime('%Y-%m-%d')
    else:
        today_kst = datetime.now(KST)
        default_end_date = today_kst.strftime('%Y-%m-%d')
        default_start_date = (today_kst - pendulum.duration(days=14)).strftime('%Y-%m-%d')
    
    if user_start_date:
        try:
            clean_date = user_start_date.strip().strip('"').strip("'")
            start_dt = pendulum.parse(clean_date, tz=KST)
            print(f"Validated start_date parameter: {clean_date}")
        except Exception as e:
            print(f"Invalid start_date format: {user_start_date}. Expected YYYY-MM-DD. Will use default: {default_start_date}")
    else:
        print(f"No start_date provided. Will use default (15 days range): {default_start_date}")
    
    if user_end_date:
        try:
            clean_date = user_end_date.strip().strip('"').strip("'")
            end_dt = pendulum.parse(clean_date, tz=KST)
            print(f"Validated end_date parameter: {clean_date}")
        except Exception as e:
            print(f"Invalid end_date format: {user_end_date}. Expected YYYY-MM-DD. Will use default: {default_end_date}")
    else:
        print(f"No end_date provided. Will use default (today): {default_end_date}")


# Define a custom slack failure notification function
def slack_failure_notification(context):
    dag_id = context.get('dag').dag_id
    task_id = context.get('task_instance').task_id
    execution_date = context.get('execution_date')
    log_url = context.get('task_instance').log_url
    
    message = f":red_circle: Task Failed\n"
    message += f"*DAG*: {dag_id}\n"
    message += f"*Task*: {task_id}\n"
    message += f"*Execution Date*: {execution_date}\n"
    message += f"*Exception*: {str(context.get('exception'))}"
    
    send_message(message=message, channel="team_da")

with DAG(
        dag_id='mart_bc',
        description=f'update table {REDSHIFT_TABLE_NAME} with minimal downtime (15 days range)',
        start_date=pendulum.datetime(2025, 7, 2, tz="Asia/Seoul"),
        schedule_interval='00 6 * * *',
        catchup=False,
        tags=['mart_bc'],
        max_active_runs=1,  # Ensure only one run at a time
        params={
            'start_date': None,  # 시작 날짜 (기본값: 14일 전)
            'end_date': None     # 종료 날짜 (기본값: 당일)
        },
        default_args={
            'owner': 'data_mart',
            'retries': 1,
            'retry_delay': pendulum.duration(minutes=5),
            'on_failure_callback': slack_failure_notification,
        }
) as dag:
    # Task 1: Validate parameters
    validate_params_task = PythonOperator(
        task_id="validate_parameters",
        python_callable=validate_params,
        provide_context=True,
    )

    # Task 2: Execute mart_bc update with temp table
    mart_bc = PythonOperator(
        task_id='mart_bc',
        python_callable=run_mart_mart_bc,
        provide_context=True,
    )

    # Task dependencies
    validate_params_task >> mart_bc








# import pendulum
# import os
# from datetime import datetime
# from airflow import DAG
# from airflow.operators.python import PythonOperator
# from airflow.providers.amazon.aws.hooks.redshift_sql import RedshiftSQLHook
# from airflow.models import Variable
# from util.slack import slack_failure_notification, send_message

# # Import local modules
# from data_mart.mart_bc.queries.query_mart_bc import execute_temp_table_merge, validate_date_parameters

# # Redshift에 업로드할 테이블 이름
# REDSHIFT_TABLE_NAME = 'doeat_data_mart.mart_bc'
# # KST timezone for date handling
# KST = pendulum.timezone("Asia/Seoul")


# def check_table_exists(table_name):
#     """Check if the table exists in Redshift"""
#     query = f"""
#     SELECT EXISTS (
#         SELECT 1 
#         FROM pg_tables 
#         WHERE schemaname = '{table_name.split('.')[0]}' 
#         AND tablename = '{table_name.split('.')[1]}'
#     );
#     """
#     hook = RedshiftSQLHook()
#     conn = hook.get_conn()
#     cursor = conn.cursor()
#     cursor.execute(query)
#     result = cursor.fetchone()
#     cursor.close()
#     conn.close()
#     return result[0]  # Returns True if table exists, False otherwise


# def run_mart_mart_bc(**context):
#     """Main function to update mart_bc mart data using temp table approach"""
#     # Get start_date from params if provided, otherwise use today's date
#     params = context.get('params', {})
#     user_start_date = params.get('start_date')
    
#     today_kst = datetime.now(KST).replace(hour=0, minute=0, second=0, microsecond=0)
    
#     if user_start_date:
#         try:
#             # Parse the provided start_date
#             start_dt = pendulum.parse(user_start_date, tz=KST)
#             start_date = start_dt.to_date_string()
#             print(f"Using provided start_date for backfill: {start_date}")
#         except Exception as e:
#             print(f"Invalid start_date format: {user_start_date}. Using today's date instead.")
#             start_date = today_kst.strftime('%Y-%m-%d')
#     else:
#         # Use today's date if no start_date is provided - only update today's data
#         start_date = today_kst.strftime('%Y-%m-%d')
#         print(f"No start_date provided. Using today's date: {start_date}")
    
#     # End date is always today
#     end_date = today_kst.strftime('%Y-%m-%d')
    
#     print(f"Processing mart_bc data from {start_date} to {end_date}")
    
#     # Check if the target table exists
#     table_exists = check_table_exists(REDSHIFT_TABLE_NAME)
    
#     # Execute the temp table merge process
#     execute_temp_table_merge(start_date, end_date, table_exists)
    
#     print("mart_bc update completed successfully")


# def validate_params(**context):
#     """Validate DAG parameters before execution"""
#     params = context.get('params', {})
#     user_start_date = params.get('start_date')
    
#     if user_start_date:
#         try:
#             start_dt = pendulum.parse(user_start_date, tz=KST)
#             today_kst = datetime.now(KST)
            
#             if start_dt > today_kst:
#                 print(f"Warning: Start date {user_start_date} is in the future. Will use today's date instead.")
#             else:
#                 print(f"Validated start_date parameter: {user_start_date}")
#         except Exception as e:
#             print(f"Invalid start_date format: {user_start_date}. Expected YYYY-MM-DD")
#     else:
#         print("No start_date provided. Will use today's date.")


# # Define a custom slack failure notification function
# def slack_failure_notification(context):
#     dag_id = context.get('dag').dag_id
#     task_id = context.get('task_instance').task_id
#     execution_date = context.get('execution_date')
#     log_url = context.get('task_instance').log_url
    
#     message = f":red_circle: Task Failed\n"
#     message += f"*DAG*: {dag_id}\n"
#     message += f"*Task*: {task_id}\n"
#     message += f"*Execution Date*: {execution_date}\n"
#     message += f"*Exception*: {str(context.get('exception'))}"
    
#     send_message(message=message, channel="team_da")

# with DAG(
#         dag_id='mart_bc',
#         description=f'update table {REDSHIFT_TABLE_NAME} with minimal downtime',
#         start_date=pendulum.datetime(2025, 7, 2, tz="Asia/Seoul"),
#         schedule_interval='40 6 * * *',
#         catchup=False,
#         tags=['mart_bc'],
#         max_active_runs=1,  # Ensure only one run at a time
#         params={
#             'start_date': None  # Default value is None, can be overridden when triggering the DAG
#         },
#         default_args={
#             'owner': 'data_mart',
#             'retries': 1,
#             'retry_delay': pendulum.duration(minutes=5),
#             'on_failure_callback': slack_failure_notification,
#         }
# ) as dag:
#     # Task 1: Validate parameters
#     validate_params_task = PythonOperator(
#         task_id="validate_parameters",
#         python_callable=validate_params,
#         provide_context=True,
#     )

#     # Task 2: Execute mart_bc update with temp table
#     mart_bc = PythonOperator(
#         task_id='mart_bc',
#         python_callable=run_mart_mart_bc,
#         provide_context=True,
#     )

#     # Task dependencies
#     validate_params_task >> mart_bc
