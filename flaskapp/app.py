from flask import Flask

import os
import sys

import urllib
import pyodbc
from sqlalchemy import create_engine, text

app = Flask(__name__)


# This is copied from docs to ensure flask is running
@app.route('/')
def hello():
    server= os.environ.get('SERVER')
    # test that environment vars are picked up
    return f"DB server: {server}"


# below is new and me attempting to connect to DB

@app.route('/test')
def test_db():
    # environment variables
    server = os.environ.get('SERVER')
    database = os.environ.get('DB')
    username = os.environ.get('USERNAME')
    password = os.environ.get('PASSWORD')
    driver = '{ODBC Driver 17 for SQL Server}'

    conn = f"""Driver={driver};Server=tcp:{server},1433;Database={database};
    Uid={username};Pwd={password};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"""

    params = urllib.parse.quote_plus(conn)
    conn_str = 'mssql+pyodbc:///?autocommit=true&odbc_connect={}'.format(params)
    engine = create_engine(conn_str, echo=True)

    print('Hello world!', file=sys.stderr)

    print(engine, file=sys.stderr)  # check console (terminal)

    from sqlalchemy import inspect
    inspector = inspect(engine)
    schemas = inspector.get_schema_names()

    for schema in schemas:
        print("schema: %s" % schema)
        for table_name in inspector.get_table_names(schema=schema):
            for column in inspector.get_columns(table_name, schema=schema):
                print("Column: %s" % column)

    return 'testing... check console.'


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=True, host='0.0.0.0', port=port)
