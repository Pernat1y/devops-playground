# About
Simple web app in Python to query DB and return REST

# Usage
Before running script, you will need to set DB connection properties:
```
db_host = '127.0.0.1'
db_user = 'root'
db_pass = 'root'
db_name = 'myapp'
```

Place 'myapp.service' in '/usr/lib/systemd/system' directory and run
```
systemctl daemon-reload
systemctl start myapp
```

