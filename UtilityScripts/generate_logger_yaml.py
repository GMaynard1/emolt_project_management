## Import necessary packages
import mysql.connector
import yaml

## Open the database connection config file
with open ("C:/Users/george.maynard/Documents/GitHubRepos/emolt_project_management/GUI/GUI-modularized/config.yml","r") as yamlfile:
  dbConfig=yaml.load(yamlfile, Loader=yaml.FullLoader)

## Connect to the development database  
devconn = mysql.connector.connect(
  user = dbConfig['default']['db_remote']['username'],
  password = dbConfig['default']['db_remote']['password'],
  host = dbConfig['default']['db_remote']['host'],
  port = dbConfig['default']['db_remote']['port'],
  database = dbConfig['default']['db_remote']['dbname']
)

import pymysql
import paramiko
import pandas as pd
from paramiko import SSHClient
from sshtunnel import SSHTunnelForwarder
from os.path import expanduser

mypkey = paramiko.RSAKey.from_private_key_file('C:\Users\george.maynard\.ssh\eMOLT_aws.pem')

sql_hostname = dbConfig['default']['db_remote']['host']
sql_username = dbConfig['default']['db_remote']['username']
sql_password = dbConfig['default']['db_remote']['password']
sql_main_database = dbConfig['default']['db_remote']['dbname']
sql_port = 3306
ssh_host = dbConfig['default']['db_remote']['host']
ssh_user = dbConfig['default']['db_remote']['ssh_user']
ssh_port = 22
sql_ip = '1.1.1.1.1'

with SSHTunnelForwarder(
        (ssh_host, ssh_port),
        ssh_username=ssh_user,
        ssh_pkey=mypkey,
        remote_bind_address=(sql_hostname, sql_port)) as tunnel:
    conn = pymysql.connect(host='127.0.0.1', user=sql_username,
            passwd=sql_password, db=sql_main_database,
            port=tunnel.local_bind_port)
    query = '''SELECT VERSION();'''
    data = pd.read_sql_query(query, conn)
    conn.close()
