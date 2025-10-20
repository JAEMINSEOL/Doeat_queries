import os
import pendulum
from datetime import datetime
from airflow.providers.amazon.aws.hooks.redshift_sql import RedshiftSQLHook

# Configuration
KST = pendulum.timezone("Asia/Seoul")
REDSHIFT_TABLE_NAME = 'doeat_data_mart.mart_bc'
TEMP_TABLE_NAME = 'tmp_mart_bc'

# Get the SQL file path
user_cnt_redshift_query_path = os.path.join(os.path.dirname(__file__), "query_mart_bc.sql")

with open(user_cnt_redshift_query_path, "r") as f:
    user_cnt_redshift_query = f.read()
    
# Define database function to execute SQL queries on Redshift

def query_to_redshift_exe(query):
    """Execute a query on Redshift without returning results"""
    hook = RedshiftSQLHook()
    conn = hook.get_conn()
    cursor = conn.cursor()
    
    # Split the query into individual statements
    statements = query.split(';')
    
    # Execute each statement separately
    for statement in statements:
        # Skip empty statements
        statement = statement.strip()
        if statement:
            cursor.execute(statement)
    
    conn.commit()
    cursor.close()
    conn.close()


def create_target_table():
    """Create the mart_bc table if it doesn't exist"""
    create_user_cnt_redshift_query = f"""
    CREATE TABLE {REDSHIFT_TABLE_NAME} AS
    {user_cnt_redshift_query}
    """

    query_to_redshift_exe(create_user_cnt_redshift_query)
    print(f"Created target table: {REDSHIFT_TABLE_NAME}")


def validate_date_parameters(user_start_date=None):
    """Validate date parameters"""
    if user_start_date:
        try:
            start_dt = pendulum.parse(user_start_date, tz=KST)
            today_kst = datetime.now(KST)
            
            if start_dt > today_kst:
                raise ValueError(f"Start date {user_start_date} cannot be in the future")
                
            print(f"Using provided start_date: {user_start_date}")
        except ValueError as ve:
            raise ve
        except Exception as e:
            raise ValueError(f"Invalid start_date format: {user_start_date}. Expected YYYY-MM-DD")
    else:
        print("Using default start_date (today)")


def execute_temp_table_merge(start_date, end_date, table_exists=True):
    """Main function to execute the complete temp table merge process"""
    # Create a single connection and cursor for the entire process
    hook = RedshiftSQLHook()
    conn = hook.get_conn()
    cursor = conn.cursor()
    
    try:
        print(f"Starting temp table merge for date range: {start_date} to {end_date}")
        
        if not table_exists:
            # If target table doesn't exist, create it directly with all data
            print(f"Target table {REDSHIFT_TABLE_NAME} does not exist. Creating it with all data...")
            create_user_cnt_redshift_query = f"""
            CREATE TABLE {REDSHIFT_TABLE_NAME} AS
            {user_cnt_redshift_query}
            """
            cursor.execute(create_user_cnt_redshift_query)
            conn.commit()
            print(f"Created target table: {REDSHIFT_TABLE_NAME}")
            return
        
        # Check if we're doing a single day update or a date range update
        is_single_day = (start_date == end_date)
        if is_single_day:
            print(f"Performing single day update for {start_date}")
        else:
            print(f"Performing date range update from {start_date} to {end_date}")
        
        # Step 1: Create temporary table
        # First drop the table if it exists
        drop_sql = f"DROP TABLE IF EXISTS {TEMP_TABLE_NAME};"
        cursor.execute(drop_sql)
        conn.commit()
        
        # Then create the temporary table
        create_sql = f"""
        CREATE TEMPORARY TABLE {TEMP_TABLE_NAME} (
            LIKE {REDSHIFT_TABLE_NAME}
        );
        """
        cursor.execute(create_sql)
        conn.commit()
        print(f"Created temporary table: {TEMP_TABLE_NAME}")
        
        # Step 2: Load data into temporary table with date filtering
        # First, get the SQL query and remove the trailing semicolon if it exists
        base_query = user_cnt_redshift_query.strip()
        if base_query.endswith(';'):
            base_query = base_query[:-1]
        
        # Insert data into temp table
        insert_temp_sql = f"""
        INSERT INTO {TEMP_TABLE_NAME}
        WITH filtered_results AS (
            {base_query}
        )
        SELECT * FROM filtered_results
        WHERE (
            -- For daily records, select rows with start_date between our date range
            (period = '일' AND start_date BETWEEN '{start_date}' AND '{end_date}')
            -- For weekly records, select rows where the date range overlaps with our period
            OR (period LIKE '주-%' AND 
                NOT (end_date < '{start_date}' OR start_date > '{end_date}'))
            -- For monthly records, select rows where the date range overlaps with our period
            OR (period = '월' AND 
                NOT (end_date < '{start_date}' OR start_date > '{end_date}'))
        );
        """
        cursor.execute(insert_temp_sql)
        conn.commit()
        print(f"Loaded data into temporary table {TEMP_TABLE_NAME} for date range {start_date} to {end_date}")
        
        # Step 3: Merge data from temp table to target table
        print("Starting merge process...")
        
        # Begin transaction
        cursor.execute("BEGIN;")
        
        # Delete existing records for the specified date range
        delete_sql = f"""
        DELETE FROM {REDSHIFT_TABLE_NAME}
        WHERE (
            -- For daily records, delete rows with start_date in our date range
            (period = '일' AND start_date BETWEEN '{start_date}' AND '{end_date}')
            -- For weekly records, delete rows where the date range overlaps with our period
            OR (period LIKE '주-%' AND 
                NOT (end_date < '{start_date}' OR start_date > '{end_date}'))
            -- For monthly records, delete rows where the date range overlaps with our period
            OR (period = '월' AND 
                NOT (end_date < '{start_date}' OR start_date > '{end_date}'))
        );
        """
        cursor.execute(delete_sql)
        
        # Insert all records from temp table
        insert_sql = f"""
        INSERT INTO {REDSHIFT_TABLE_NAME}
        SELECT * FROM {TEMP_TABLE_NAME};
        """
        cursor.execute(insert_sql)
        
        # Commit transaction
        cursor.execute("COMMIT;")
        conn.commit()
        print(f"Merged data from {TEMP_TABLE_NAME} to {REDSHIFT_TABLE_NAME} for date range {start_date} to {end_date}")
        
        # Step 4: Clean up - drop temp table
        drop_temp_sql = f"DROP TABLE IF EXISTS {TEMP_TABLE_NAME};"
        cursor.execute(drop_temp_sql)
        conn.commit()
        print(f"Dropped temporary table: {TEMP_TABLE_NAME}")
        
        print("Temp table merge process completed successfully")
        
    except Exception as e:
        print(f"Error in temp table merge process: {str(e)}")
        # Clean up temp table if it exists
        try:
            drop_temp_sql = f"DROP TABLE IF EXISTS {TEMP_TABLE_NAME};"
            cursor.execute(drop_temp_sql)
            conn.commit()
            print(f"Dropped temporary table: {TEMP_TABLE_NAME}")
        except:
            pass  # Ignore cleanup errors
        conn.rollback()  # Roll back any pending transactions
        raise e
    finally:
        # Always close cursor and connection
        cursor.close()
        conn.close()
