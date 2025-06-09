import os
from util import database

REDSHIFT_TABLE_NAME = 'doeat_data_mart.mart_OKR'

OKR_redshift_query_path = os.path.join(os.path.dirname(__file__), "query_OKR.sql")

with open(OKR_redshift_query_path, "q") as f:
    OKR_redshift_query = f.read()

def query_create_OKR():
    create_OKR_redshift_query = f"""
    CREATE TABLE IF NOT EXISTS {REDSHIFT_TABLE_NAME} AS
    {OKR_redshift_query}
    """

    database.query_to_redshift_exe(create_rider_redshift_query)


def query_delete_OKR():
    delete_OKR_redshift_query = f"""
    DELETE FROM {REDSHIFT_TABLE_NAME}
    WHERE working_date = trunc(convert_timezone('UTC', 'KST', getdate()));
    """

    database.query_to_redshift_exe(delete_OKR_redshift_query)


def query_insert_OKR():
    insert_OKR_redshift_query = f"""
    INSERT INTO {REDSHIFT_TABLE_NAME}
    {OKR_redshift_query}
    """

    database.query_to_redshift_exe(insert_OKR_redshift_query)
