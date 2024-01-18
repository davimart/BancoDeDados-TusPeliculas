
import psycopg2

def connect_to_database():
    host = input("Enter host: ")
    database = input("Enter database name: ")
    user = input("Enter username: ")
    password = input("Enter password: ")
    port = input("Enter port: ")

    connection = psycopg2.connect(
        host=host,
        database=database,
        user=user,
        password=password,
        port = port
    )

    return connection

def execute_query(cursor, query, data=None):
    cursor.execute(query, data)
    cursor.connection.commit()
