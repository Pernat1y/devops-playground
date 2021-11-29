#!/usr/bin/python3

from http.server import BaseHTTPRequestHandler
from http.server import HTTPServer
try:
    import pymysql.cursors
except ImportError:
    print('I need MySQLdb extension. Exiting.')
    exit()


# DB options
db_host = '10.1.0.52'
db_user = 'root'
db_pass = 'root'
db_name = 'myapp'

timeout = 10
listen_host = '0.0.0.0'
listen_port = 8080

# Connect to the database
def db_connect():
    connection = pymysql.connect(host=db_host,
                                 user=db_user,
                                 password=db_pass,
                                 database=db_name,
                                 cursorclass=pymysql.cursors.DictCursor)
    return connection

def create_test_data():
    connection = db_connect()
    with connection.cursor() as cursor:
        # Create a new record
        sql = "INSERT INTO `data` (`a`, `b`) VALUES (%s, %s)"
        cursor.execute(sql, ('testing123', 'abc123'))

    # connection is not autocommit by default. So you must commit to save
    # your changes.
    connection.commit()

def query_db():
    connection = db_connect()
    with connection.cursor() as cursor:
        # Read a single record
        sql = "SELECT `a` FROM `data` WHERE `id`=1"
        cursor.execute(sql)
        result = cursor.fetchone()
        return result

class HttpGetHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Query DB
        result = query_db()

        # Send results
        if result:
            print(f'Got results from DB query: {result}')
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(str(result).encode())
        else:
            self.send_response(500)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write('Something went wrong while querying backend DB.'.encode())

def run(server_class=HTTPServer, handler_class=HttpGetHandler):
    server_address = ('', listen_port)
    httpd = server_class(server_address, handler_class)
    try:
        print(f'Listening *:{listen_port}')
        httpd.serve_forever()
    except KeyboardInterrupt:
        httpd.server_close()


create_test_data()  # Create test db with data
run()  # Start server
