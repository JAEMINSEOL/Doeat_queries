import pendulum
from airflow import DAG
from airflow.operators.python import PythonOperator
from data_mart.rider.queries.query_rider import query_create_rider, query_delete_rider, query_insert_rider
from util import database
from util.slack import slack_failure_notification

# Redshift에 업로드할 테이블 이름
REDSHIFT_TABLE_NAME = 'doeat_data_mart.mart_OKR'


def check_table_exists(table_name):
    query = f"""
    SELECT EXISTS (
        SELECT 1 
        FROM pg_tables 
        WHERE schemaname = '{table_name.split('.')[0]}' 
        AND tablename = '{table_name.split('.')[1]}'
    );
    """
    result = database.query_to_redshift(query)
    return result[0][0]  # Returns True if table exists, False otherwise


def run_mart_OKR():
    # Check if the table exists
    table_exists = check_table_exists(REDSHIFT_TABLE_NAME)

    if table_exists:
        # If table exists, delete current date's data and insert new data
        query_delete_OKR()
        query_insert_OKR()
    else:
        # If table doesn't exist, create it with all data
        query_create_OKR()


with DAG(
        dag_id='OKR_mart',
        description=f'update table {REDSHIFT_TABLE_NAME}',
        start_date=pendulum.datetime(2025, 6, 9, tz="Asia/Seoul"),
        schedule_interval='15,45 * * * *',
        catchup=False,
        tags=['OKR'],
        default_args={
            'owner': 'data_mart',
            'retries': 0,
            'on_failure_callback': slack_failure_notification,
        }
) as dag:
    # 날짜별 데이터 처리 태스크
    rider_mart = PythonOperator(
        task_id='mart_OKR',
        python_callable=run_mart_OKR
    )

    OKR_mart
