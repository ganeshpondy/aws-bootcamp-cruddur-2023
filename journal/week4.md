# Week 4 — Postgres and RDS

Note: 
* Hide dynamodb Steps in Docker-Compose file
* Stopping RDS Instance is only for 7 Days, Instance will auto start after 7 days. make a note and take action accordingly  

Summary:
--------
**Local DB**
01. Start postgres DB Container
01. Connect the DB from Server
01. Create Table
01. Update Schema Structure into the Table
01. Insert data into the Table, as per the Schema Structure

**AWS RDS**
01. Create AWS RDS 
01. Create Table, Update Schema
01. In Cruddur, When new User Sigin-up, once user verfication complete. the user information will save to AWS RDS DB.
01. Using Amazon Cognito, you easily add user sign-up and authentication to your mobile and web apps.
01. when user is verified, Lambda is triggred from Cognito.
01. Lambda will collect the user information and save it in the RDS 'users' table.
01. Users post details are saved in 'activities' table under 'user_uuid'


## Create AWS RDS Instance
Create a RDS Postgres instance using AWS CLI

```sh
aws rds create-db-instance \
	--db-instance-identifier cruddur-db-instance \
	--db-instance-class db.t3.micro \
	--engine postgres \
	--engine-version  14.6 \
	--master-username <username> \
	--master-user-password <dbpassword> \
	--allocated-storage 20 \
	--availability-zone ap-south-1a \
	--backup-retention-period 0 \
	--port 5432 \
	--no-multi-az \
	--db-name cruddur \
	--storage-type gp2 \
	--publicly-accessible \
	--storage-encrypted \
	--enable-performance-insights \
	--performance-insights-retention-period 7 \
	--no-deletion-protection
```

<img src="./Images/Week-04/DB-Instance-Create.JPG"  width="50%" height="50%">

If you want to stop, Select below options:

<img src="./Images/Week-04/DB-Instance-Stop.JPG"  width="50%" height="100%">


## Local Postgres Database

`docker-compse` file is having Postgres DB Container details, DB will be started, when we are stating the Containers.

Connect to Local DB, user name: postgres Password is password 
To connect to psql via the psql client cli tool remember to use the host flag to specific localhost.

```BASH
psql -Upostgres --host localhost
```

```SQL
$ psql -U postgres --host localhost
Password for user postgres: 
psql (13.10 (Ubuntu 13.10-1.pgdg20.04+1))
Type "help" for help.

postgres=# 
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)

postgres=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of 
-----------+------------------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}

postgres=# \dn
  List of schemas
  Name  |  Owner   
--------+----------
 public | postgres
(1 row)

postgres=# 
```

General PSQL command options:

```sql
\l -- List all databases
\dt -- List all tables in the current database
\x on -- expanded display when looking at data
\x auto
\x off
\q -- Quit PSQL
\c database_name -- Connect to a specific database
\d table_name -- Describe a specific table
\du -- List all users and their roles
\dn -- List all schemas in the current database
SELECT * FROM users;
SELECT uuid,user_uuid,message FROM activities;
CREATE DATABASE database_name; -- Create a new database
DROP DATABASE database_name; -- Delete a database
CREATE TABLE table_name (column1 datatype1, column2 datatype2, ...); -- Create a new table
DROP TABLE table_name; -- Delete a table
SELECT column1, column2, ... FROM table_name WHERE condition; -- Select data from a table
INSERT INTO table_name (column1, column2, ...) VALUES (value1, value2, ...); -- Insert data into a table
UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition; -- Update data in a table
DELETE FROM table_name WHERE condition; -- Delete data from a table
```

#### Connection url format for psql

```SQL
postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]
```

#### For LocalHost DB Connection
```BASH
export CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"

gp env CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
```

#### To Connect AWS RDS

```BASH
export PROD_CONNECTION_URL="postgresql://userid:password@cruddur-db-instance.c8tl2cyfj5ba.ap-south-1.rds.amazonaws.com:5432/cruddur"

gp env PROD_CONNECTION_URL="postgresql://userid:password@cruddur-db-instance.c8tl2cyfj5ba.ap-south-1.rds.amazonaws.com:5432/cruddur"

```
</br>

#### Create DB 'cruddur'

```BASH
CREATE DATABASE cruddur;
```

```SQL
postgres=# CREATE DATABASE cruddur;
CREATE DATABASE
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 cruddur   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(4 rows)

postgres=# \q

```

#### To Check Connection DB with password

```BASH
$ psql postgresql://postgres:password@localhost:5432/cruddur
psql (13.10 (Ubuntu 13.10-1.pgdg20.04+1))
Type "help" for help.

cruddur=# 
```

#### Script to Connect DB

Script is saved in Path: `backend-flask/bin/db-connect`

Change the script permissions:
```BASH
chmod 755 ./backend-flask/bin/db-*
```

```BASH
#! /usr/bin/bash
if [ "$1" = "prod" ]; then
  echo "############################"
  echo "Running in production mode"
  echo "############################"
  URL=$PROD_CONNECTION_URL
else
  echo "####################################"
  echo "Connecting Local Postgres SQL...."
  echo "####################################"
  URL=$CONNECTION_URL
fi

psql $URL
```

To Connect Local DB:

```SQL
$ ./bin/db-connect 
####################################
Connecting Local Postgres SQL....
####################################
psql (13.10 (Ubuntu 13.10-1.pgdg20.04+1))
Type "help" for help.

cruddur=# \dt
           List of relations
 Schema |    Name    | Type  |  Owner   
--------+------------+-------+----------
 public | activities | table | postgres
 public | users      | table | postgres
(2 rows)
cruddur=# 
```

### Create DataBase

We can use the createdb command to create our database:


```
createdb cruddur -h localhost -U postgres
```

```sh
psql -U postgres -h localhost
```

We can create the database within the PSQL client

```sql
CREATE database cruddur;
```
#### Script to Create DB

Script is saved in Path: `backend-flask/bin/db-create`

Change the script permissions:
```BASH
chmod 755 ./backend-flask/bin/db-*
```

```BASH
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-create"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

echo "DB-CREATE"

NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "CREATE DATABASE cruddur;"
```

To Connect Local DB:

```SQL
$ ./bin/db-create 
== db-create
DB-CREATE
CREATE DATABASE
```


#### Script to Load Schema

Script is saved in Path: `backend-flask/bin/db-schema-load`

Change the script permissions:
```BASH
chmod 755 ./backend-flask/bin/db-*
```

```BASH
#! /usr/bin/bash

schema_path="$(realpath .)/db/schema.sql"

echo $schema_path

if [ "$1" = "prod" ]; then
  echo "############################"
  echo "Running in production mode"
  echo "############################"
  URL=$PROD_CONNECTION_URL
else
  echo "####################################"
  echo "Connecting Local Postgres SQL...."
  echo "####################################"
  URL=$CONNECTION_URL
fi

psql $URL cruddur < $schema_path
```
Schema File

```SQL
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.activities;


CREATE TABLE public.users (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  display_name text NOT NULL,
  handle text NOT NULL,
  email text NOT NULL,
  cognito_user_id text NOT NULL,
  created_at TIMESTAMP default current_timestamp NOT NULL
);

CREATE TABLE public.activities (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_uuid UUID NOT NULL,
  message text NOT NULL,
  replies_count integer DEFAULT 0,
  reposts_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  reply_to_activity_uuid integer,
  expires_at TIMESTAMP,
  created_at TIMESTAMP default current_timestamp NOT NULL
);
```

To Load Schema:

```SQL
$ ./bin/db-schema-load 
== db-schema-load
/workspace/aws-bootcamp-cruddur-2023/backend-flask/db/schema.sql
Connecting Local Postgres SQL....
CREATE EXTENSION
NOTICE:  table "users" does not exist, skipping
DROP TABLE
NOTICE:  table "activities" does not exist, skipping
DROP TABLE
CREATE TABLE
CREATE TABLE
$
```

#### Seed Data into DB Table

#### Script to Seed

Script is saved in Path: `backend-flask/bin/db-seed`

Change the script permissions:
```BASH
chmod 755 ./backend-flask/bin/db-*
```

```BASH
#! /usr/bin/bash

seed_path="$(realpath .)/db/seed.sql"
echo $seed_path

if [ "$1" = "prod" ]; then
  echo "############################"
  echo "Running in production mode"
  echo "############################"
  URL=$PROD_CONNECTION_URL
else
  echo "####################################"
  echo "Connecting Local Postgres SQL...."
  echo "####################################"
  URL=$CONNECTION_URL
fi

psql $URL cruddur < $seed_path
```

To seed.sql:

```SQL
-- this file was manually created
INSERT INTO public.users (display_name, handle, cognito_user_id)
VALUES
  ('Andrew Brown', 'andrewbrown' ,'MOCK'),
  ('Andrew Bayko', 'bayko' ,'MOCK'),
  ('Ganesh B', 'ganeshpondy' ,'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'andrewbrown' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  )
```

<img src="./Images/Week-04/Local_Postgres_DB_Query.JPG"  width="50%" height="100%">

</br>
</br>

**To Connect Local DB:**

```SQL
$ ./bin/db-seed 
== db-seed
/workspace/aws-bootcamp-cruddur-2023/backend-flask/db/seed.sql
####################################
Connecting Local Postgres SQL....
####################################
INSERT 0 3
INSERT 0 1
gitpod /workspace/aws-bootcamp-cruddur-2023/backend-flask (main) $ 

```

Connect DB and Verify the tables:

```SQL
$ ./bin/db-connect 
####################################
Connecting Local Postgres SQL....
####################################
psql (13.10 (Ubuntu 13.10-1.pgdg20.04+1))
Type "help" for help.

cruddur=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 cruddur   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(4 rows)

cruddur=# \t
Tuples only is on.
cruddur=# \dt
 public | activities | table | postgres
 public | users      | table | postgres

cruddur=#
cruddur=# SELECT * FROM users;
 650bfddf-6459-4a9a-b602-9f1300c37d5c | Andrew Brown | andrewbrown | MOCK            | 2023-03-12 13:26:00.074107
 d690406b-b00a-421c-90fd-be2325b786d8 | Andrew Bayko | bayko       | MOCK            | 2023-03-12 13:26:00.074107
 1d7ed6f4-dd3d-4312-a407-09ab7e19b840 | Ganesh B     | ganeshpondy | MOCK            | 2023-03-12 13:26:00.074107

cruddur=# 

cruddur=# \x on
Expanded display is on.
cruddur=# SELECT * FROM activities;
uuid                   | 8314cd82-1c5b-448d-a17f-17decffaf7f0
user_uuid              | 650bfddf-6459-4a9a-b602-9f1300c37d5c
message                | This was imported as seed data!
replies_count          | 0
reposts_count          | 0
likes_count            | 0
reply_to_activity_uuid | 
expires_at             | 2023-03-22 13:26:00.076065
created_at             | 2023-03-12 13:26:00.076065

cruddur=# 

cruddur=# \x auto
Expanded display is used automatically.
cruddur=# SELECT * FROM activities;
uuid                   | 8314cd82-1c5b-448d-a17f-17decffaf7f0
user_uuid              | 650bfddf-6459-4a9a-b602-9f1300c37d5c
message                | This was imported as seed data!
replies_count          | 0
reposts_count          | 0
likes_count            | 0
reply_to_activity_uuid | 
expires_at             | 2023-03-22 13:26:00.076065
created_at             | 2023-03-12 13:26:00.076065

cruddur=# 
```
</br>

#### To Check the DB sessions

##### Script to verify the Sessions

Script is saved in Path: `backend-flask/bin/db-sessions`

Change the script permissions:
```BASH
chmod 755 ./backend-flask/bin/db-*
```

```BASH
#! /usr/bin/bash

if [ "$1" = "prod" ]; then
  echo "############################"
  echo "Running in production mode"
  echo "############################"
  URL=$PROD_CONNECTION_URL
else
  echo "####################################"
  echo "Connecting Local Postgres SQL...."
  echo "####################################"
  URL=$CONNECTION_URL
fi

NO_DB_URL=$(sed 's/\/cruddur//g' <<<"$URL")
psql $NO_DB_URL -c "select pid as process_id, \
       usename as user,  \
       datname as db, \
       client_addr, \
       application_name as app,\
       state \
from pg_stat_activity;"
```

```SQL
$ ./bin/db-sessions 
== db-sessions
####################################
Connecting Local Postgres SQL....
####################################
 process_id |   user   |    db    | client_addr | app  | state  
------------+----------+----------+-------------+------+--------
         71 |          |          |             |      | 
         73 | postgres |          |             |      | 
         78 | postgres | postgres | 172.18.0.1  | psql | active
         69 |          |          |             |      | 
         68 |          |          |             |      | 
         70 |          |          |             |      | 
(6 rows)

gitpod /workspace/aws-bootcamp-cruddur-2023/backend-flask (main) $ 
```
</br>

#### All DB Steps in a Single File 'db-setup'


#### Script to verify the Sessions

Script is saved in Path: `backend-flask/bin/db-setup`

Change the script permissions:
```BASH
chmod 755 ./backend-flask/bin/db-*
```

```BASH
#! /usr/bin/bash
-e # stop if it fails at any point

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-setup"
printf "${CYAN}==== ${LABEL}${NO_COLOR}\n"

bin_path="$(realpath .)/bin"

source "$bin_path/db-drop"
source "$bin_path/db-create"
source "$bin_path/db-schema-load"
source "$bin_path/db-seed"
```

```SQL
$ ./bin/db-setup 
./bin/db-setup: line 2: -e: command not found
==== db-setup
== db-drop
DB-DROP
ERROR:  database "cruddur" does not exist

== db-create
DB-CREATE
CREATE DATABASE

== db-schema-load
/workspace/aws-bootcamp-cruddur-2023/backend-flask/db/schema.sql
####################################
Connecting Local Postgres SQL....
####################################
CREATE EXTENSION
NOTICE:  table "users" does not exist, skipping
DROP TABLE
NOTICE:  table "activities" does not exist, skipping
DROP TABLE
CREATE TABLE
CREATE TABLE

== db-seed
/workspace/aws-bootcamp-cruddur-2023/backend-flask/db/seed.sql
####################################
Connecting Local Postgres SQL....
####################################
INSERT 0 3
INSERT 0 1
gitpod /workspace/aws-bootcamp-cruddur-2023/backend-flask (main) $ 

```
</br>

#### Connecting to DB

```PYRHON
from datetime import datetime, timedelta, timezone
from opentelemetry import trace

## Week-04 PostgreSQL
from lib.db import pool

tracer = trace.get_tracer("home.activities")

class HomeActivities:
  def run(cognito_user_id=None):
    #logger.info("HomeActivities")
    with tracer.start_as_current_span("home-activites-mock-data"):
      span = trace.get_current_span()
      now = datetime.now(timezone.utc).astimezone()
      span.set_attribute("app.now", now.isoformat())
      
      # Week-04 PostgreSQL
      sql = """
      SELECT * FROM activities;      
      """
      with pool.connection() as conn:
        with conn.cursor() as cur:
          cur.execute(sql)
          # this will return a tuple
          # the first field being the data
          json = cur.fetchone()
      return json[0]
      return results
	  
```
---

## AWS RDS PostgreSQL

* Start `cruddur-db-instance` DB Instance
* Check the `env` variable in backend container
  ```BASH
  $ env | grep -i PROD_CONNECTION_URL
  PROD_CONNECTION_URL=postgresql://username:Password@cruddur-db-instance.c8tl2cyfj5ba.ap-south-1.rds.amazonaws.com:5432/cruddur
  ```
* add out client/getpod IP into RDS Security Group
  	Security Group:			sg-id
  	Security group rule ID: sgr-id
    ```BASH
    GITPOD_IP=$(curl ifconfig.me)
    echo $GITPOD_IP
    ```

* Add the Gitpod ip in SG Rules.
* Then Connect the RDS

  ```SQL
  gitpod /workspace/aws-bootcamp-cruddur-2023 (main) $ psql $PROD_CONNECTION_URL
  psql (13.10 (Ubuntu 13.10-1.pgdg20.04+1), server 14.6)
  WARNING: psql major version 13, server major version 14.
          Some psql features might not work.
  SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
  Type "help" for help.

  cruddur=> \l
  cruddur   | cruddurroot | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
  postgres  | cruddurroot | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
  rdsadmin  | rdsadmin    | UTF8     | en_US.UTF-8 | en_US.UTF-8 | rdsadmin=CTc/rdsadmin      +
            |             |          |             |             | rdstopmgr=Tc/rdsadmin
  template0 | rdsadmin    | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/rdsadmin                +
            |             |          |             |             | rdsadmin=CTc/rdsadmin
  template1 | cruddurroot | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/cruddurroot             +
            |             |          |             |             | cruddurroot=CTc/cruddurroot
  cruddur=> 
  ```

* We will be getting new IP, Everytime we open new GitPod Session. So the IP need to add in RDS Secutiry Groups in bound rule to connect GitPod with RDS.
  Follow Below command to update the IP.

  ```BASH
  export DB_SG_ID="sg-id"
  gp env DB_SG_ID="sg-id"
  export DB_SG_RULE_ID="sgr-id"
  gp env DB_SG_RULE_ID="sgr-id"

  aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={Description=GITPOD,IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
	 ```
  Command Output:

  ```BASH
  gitpod /workspace/aws-bootcamp-cruddur-2023 (main) $ aws ec2 modify-security-group-rules \
  >     --group-id $DB_SG_ID \
  >     --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={Description=GITPOD,IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
  {
      "Return": true
  }
  ```

Create script to auto update everytime:

Script Path: `bin/rds-update-sg-rule`

```BASH
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="rds-update-sg-rule"
printf "${CYAN}==== ${LABEL}${NO_COLOR}\n"

aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={Description=GITPOD,IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
```


After Updating Rule:
  <img src="./Images/Week-04/Before_Adding_GitPod_IP.JPG"  width="50%" height="100%">
  <img src="./Images/Week-04/After_Adding_GitPod_IP.JPG"  width="50%" height="100%">

Update below line in `.gitpod.yml` file:

```YAML
    command: |
      export GITPOD_IP=$(curl ifconfig.me)
      source  "$THEIA_WORKSPACE_ROOT/backend-flask/bin/rds-update-sg-rule"
```

Reload the GitPod and try to Connect Prod AWS RDS

```
./bin/db-connect prod
```

```SQL
gitpod /workspace/aws-bootcamp-cruddur-2023/backend-flask (main) $ ./bin/db-connect prod
############################
Running in production mode
############################
psql (13.10 (Ubuntu 13.10-1.pgdg20.04+1), server 14.6)
WARNING: psql major version 13, server major version 14.
         Some psql features might not work.
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

cruddur=> \l
                                      List of databases
   Name    |    Owner    | Encoding |   Collate   |    Ctype    |      Access privileges      
-----------+-------------+----------+-------------+-------------+-----------------------------
 cruddur   | cruddurroot | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 postgres  | cruddurroot | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 rdsadmin  | rdsadmin    | UTF8     | en_US.UTF-8 | en_US.UTF-8 | rdsadmin=CTc/rdsadmin      +
           |             |          |             |             | rdstopmgr=Tc/rdsadmin
 template0 | rdsadmin    | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/rdsadmin                +
           |             |          |             |             | rdsadmin=CTc/rdsadmin
 template1 | cruddurroot | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/cruddurroot             +
           |             |          |             |             | cruddurroot=CTc/cruddurroot
(5 rows)

cruddur=> \dt
Did not find any relations.
cruddur=> 
```

Update `backend-flask` docker-compose file for RDS
```YAML
      CONNECTION_URL: "${PROD_CONNECTION_URL}"
```

Load DB Schems to RDS DB

```SQL
$ ./bin/db-schema-load prod
== db-schema-load
/workspace/aws-bootcamp-cruddur-2023/backend-flask/db/schema.sql
############################
Running in production mode
############################
CREATE EXTENSION
NOTICE:  table "users" does not exist, skipping
DROP TABLE
NOTICE:  table "activities" does not exist, skipping
DROP TABLE
CREATE TABLE
CREATE TABLE
gitpod /workspace/aws-bootcamp-cruddur-2023/backend-flask (main) $ 

```

---

## LAMBDA

1. Add Code and press "Deploy"

1. Create Layer
    * Create ZIP Package for Layer
    * Add the File into Layer
1. Add Layer to Lambda
1. Configuration => Permission => Execution role => Click On the role => 
	will open IAM Page => Add Permission => Create inline Policy
1. Go to Configuration => Permission => Resource Summaru => Drop Down => Select EC2

1. VPC => Create VPC => Refer Scren Shot

1. To View Logs (cloudwatch)
  Monitor => Click on view cloudwatch logs
    => We can view Lambda logs in cloudwatch

1. Add Lambda trigger in Cognito
  Go to Cognito => User pools ==> cruddur-user-pool
	User pool properties => Lambda triggers => Add Lambda trigger

### Create Lambd Fuction

<img src="./Images/Week-04/Lambda_new-1.JPG"  width="50%" height="100%">

<img src="./Images/Week-04/Lambda_new-2.JPG"  width="50%" height="50%">


### Code Deploy

Code is avaiable in `aws-bootcamp-cruddur-2023/aws/lambdas/` path

`cruddur-post-confirrmation_Layer.py` code is having vulnerability issues so at the later stage, code has been updated to `cruddur-post-confirrmation.py`

Paste the code and press `Deploy`

<img src="./Images/Week-04/Lambda_Code-Deploy.JPG"  width="50%" height="100%">


### Create Layer

<img src="./Images/Week-04/Create_Layer_1.JPG"  width="50%" height="100%">

<img src="./Images/Week-04/Create_Layer_2.JPG"  width="50%" height="100%">

<img src="./Images/Week-04/Create_Layer_3.JPG"  width="50%" height="100%">


### Create Zip File for Layer

Use the Following Steps to Create Package File for Layer. Need to create these steps in your local Machine or Latop

```BASH

mkdir aws-psycopg2
cd aws-psycopg2
--------------------------------------------------------------------------------
vi get_layer_packages.sh

#!/bin/bash
export PKG_DIR="python"
rm -rf ${PKG_DIR} && mkdir -p ${PKG_DIR}
docker run --rm -v $(pwd):/foo -w /foo lambci/lambda:build-python3.6 \
    pip install -r requirements.txt --no-deps -t ${PKG_DIR}
--------------------------------------------------------------------------------
vi requirements.txt
aws-psycopg2
--------------------------------------------------------------------------------
then do : chmod +x get_layer_packages.sh
--------------------------------------------------------------------------------
./get_layer_packages.sh
--------------------------------------------------------------------------------
zip -r aws-psycopg2.zip .
--------------------------------------------------------------------------------

upload this zip to the AWS Lambda Layer!
```


### Add Layer to Lambda

<img src="./Images/Week-04/Add_Layer_1.JPG"  width="50%" height="100%">


### Add Layer to Lambda

Add IAM Role:
Click on the popup link, it will open IAM Page

<img src="./Images/Week-04/Lambda_Permission_IAM_1.JPG"  width="50%" height="100%">

<img src="./Images/Week-04/Lambda_Permission_IAM_2.JPG"  width="50%" height="100%">

<img src="./Images/Week-04/Lambda_Permission_IAM_3.JPG"  width="50%" height="50%">

<img src="./Images/Week-04/Lambda_Permission_IAM_4.JPG"  width="50%" height="50%">

<img src="./Images/Week-04/Lambda_Permission_IAM_5.JPG"  width="50%" height="100%">

</br>
</br>

Cli Command to View the Lambda Layer Details:

```
aws lambda get-layer-version-by-arn --arn "<Layer-ID>"
```
```YAML
$ aws lambda get-layer-version-by-arn --arn "arn:aws:lambda:ap-south-1:675982193808:layer:psycopg2-py38:3"
{
    "Content": {
        "Location": "https://awslambda-ap-s-1-layers.s3.ap-south-1.amazonaws.com/snapshots/675982193808/psycopg2-py38-1da7f52c-1e0d-4193-8794-369e38ea3b95?versionId=EWIt0XdHq0.6ljd21.wkleOnBPCgYVw0&X-Amz-Security-Token=IQoJb3JpZ2luX2VjECsaCmFwLXNvdXRoLTEiSDBGAiEAoW4k6mAYmXv4%2BAsh%2F2kFDIx5pQs3ed4bSp9LOOiTHSsCIQDC1WiL8X4CBQHP4ghZ4rfmBoHXab3uT%2BnbQBtDLexlsSq9BQjj%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAMaDDU0NTI1NTIwMTMwNyIMnifWIzhczmlPM4vdKpEFDqaTTKgpGaaDT1HmnIAhGdRQN9uXo0rG5%2B%2BHu0YEB%2FJx2cObLlVAIlWSx%2B19RN2pYPDxsvSprVweE6Clhu9KQObNGiMvQRdh0uYcAOav67wLOh9%2B0RutCdCx0ediFtW9sGRhyew6jjdapOVujPY37GZCwdh7ujUPYSWVQ%2FcBpnrwI4pDXORcJ%2B%2Fa%2BLYrZfOPW0s96bEzRS%2BydW%2BFDXg3V4IXohDfxOopvIBZxZqdOcZYj7h402TcrO24BOLCevB4kndojWpyXGvYr%2BZmyxG2UEbOVCdzIOJe2mf9PZH6Fvel07hrDVUa%2FwtNhrsyuE7Q2uSE81Ng%2BTUdwHfcaed2hrI1lEO124wlSKw1FeHAXooEvPfHtfH6WuVax95OSflOkarTp1YzEYOfH9ozUWlo%2FB8h1UR2EJEvGZOb%2F%2Fsd5jpD7OA%2B8ROEREMnpPkJobRgaV467soGtT2ueWk9Wnv3HEECm7LaHCmwBy6ElYfHOF5EKeLbmEXNvyu5yDXuWbKbfX%2BECqmn4SoYVjjWoPo6W%2BkzMJGkbW42jnmLDE4jkb0%2FwluXjgwNvtvvHE940OlQtdRpnwweu427iRCL0GNfq3InRM%2FJ8Pei5QYDE%2B2pp%2FXcvhS%2FRuu9BxOEImL18ao%2Bz7PaQfK6HJ5NySmIO3587dNMeCWpKZdw%2BBo1QaE6rkyK2Xw%2F6qgcpBsGcgtuL9NDc2l5I%2FeK447iXqxxTKW4jHGsFR%2FRL8wQF%2FjEhdXXfOYyEM%2BuTESW6mlyZ2RFwo7jTiNIEMaCy4mpuIVaYV3XBlWPX6SePs9gBhzweXz7ZbdZsZGGaZYvg02OOxuAo4%2FJ%2BmGM%2BYssHk3vZ0iJ8NDqIF20lbNx%2B8nCjlsByexH1PKRMKHrxKAGOrABJmEFYF9RWdDzQVNyYMtxAKxYPNG4CYWjNMSlsY7viM362CYX9s%2FsH%2BlzjM5XuxbfaQrqY377cU89TqWtjkzUSkyYXvjY%2B3GkYHYGF20HJFcamkNux4EeR2xXO99j4LVTvVPyAS0iRhyLVuBJSZNYOyOBWsCCncNPuGtVvNiiqz%2FUJoNeDe1E6Z9QFVx%2BT1%2FXjwAxO3nF3Y9BF8vmc%2B90Emkm7Mfqf5H584XXcv%2F717w%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230315T032717Z&X-Amz-SignedHeaders=host&X-Amz-Expires=600&X-Amz-Credential=ASIAX5456DIN6AMOOANR%2F20230315%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Signature=08352f1676b6acaa4380557bc0bff4cdabd7aa9ba58e2198d7065719ede64add",
        "CodeSha256": "cS2XLlCkcm2WcNMDPHz54yHOJh7sRFZ2jUCBhE29YNg=",
        "CodeSize": 3526120
    },
    "LayerArn": "arn:aws:lambda:ap-south-1:675982193808:layer:psycopg2-py38",
    "LayerVersionArn": "arn:aws:lambda:ap-south-1:675982193808:layer:psycopg2-py38:3",
    "Description": "",
    "CreatedDate": "2023-03-15T03:20:07.703+0000",
    "Version": 3,
    "CompatibleRuntimes": [
        "python3.8"
    ]
}
gitpod /workspace/aws-bootcamp-cruddur-2023 (main) $ 
```

#### IAM Policy

```JSON
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
}
```

Go to "Resource Summary", Click on the Drop Menu and Select "Amazon EC2". then you can see the policy details
<img src="./Images/Week-04/Lambda_Create_1.JPG"  width="50%" height="100%">

### VPC

GitPod IP is automatcially Added into the SecurityGroup

<img src="./Images/Week-04/Lambda_Create_VPC_1.JPG"  width="50%" height="100%">

Go VPC => VPC => Click on the Group `vpc-0b7ecada6e605cc80`

<img src="./Images/Week-04/Lambda_Create_VPC_2.JPG"  width="50%" height="100%">

VPC Page will open and Find the VPC Resource Map Details:

<img src="./Images/Week-04/Lambda_Create_VPC_3.JPG"  width="50%" height="100%">

### Add Lambda into Cognito

Open Cognito page, Select the UserPool and Add the Lambda Trigger

<img src="./Images/Week-04/Lambda_Add_Cognito.JPG"  width="50%" height="100%">

----

### Registor User

Open Cruddur App and click on "Join" Button:

<img src="./Images/Week-04/Join.JPG"  width="=10%" height="50%">

Provied the Required Details

<img src="./Images/Week-04/Join_Details.JPG"  width="50%" height="100%">

OTP will send to mail id, Enter the OTP in this Window.

<img src="./Images/Week-04/Join_OTP.JPG"  width="50%" height="100%">

Now you can login with the USER and Password to Cruddur App

<img src="./Images/Week-04/Login.JPG"  width="50%" height="100%">

Connect RDS DB to view the New User Details in the Table:

```SQL
cruddur=> select * from users;
                 uuid                 | display_name |   handle   |        email         |           cognito_user_id            |         created_at         
--------------------------------------+--------------+------------+----------------------+--------------------------------------+----------------------------
 4820dc8e-265f-49a2-ad1a-22a8effd07be | ganeshlive   | ganeshlive | id@mail.com | 3b957104-6bd3-4e3d-bd86-3f13f7fbef59 | 2023-03-16 01:42:05.907553
(1 row)
cruddur=> 

cruddur=> \x on
Expanded display is on.

cruddur=> select * from users;
-[ RECORD 1 ]---+-------------------------------------
uuid            | e6de7eed-718f-4283-981c-290364b495c6
display_name    | ganeshlive
handle          | ganeshlive
email           | id@mail.com
cognito_user_id | 598efa71-f203-402b-b41c-6f132a0678da
created_at      | 2023-03-16 10:16:49.454744
cruddur=> 
```

### Post Message 

<img src="./Images/Week-04/Post_Message.JPG"  width="50%" height="100%">

Posting Messages with Different Login ID's

<img src="./Images/Week-04/ganeshlive-message.JPG"  width="50%" height="100%">
<img src="./Images/Week-04/ganeshnir-message.JPG"  width="50%" height="100%">

</br>
</br>

##### Connect RDS DB to view the Post Details and Users Details:

User Details:

<img src="./Images/Week-04/table-users.JPG"  width="50%" height="100%">

Post Details:

<img src="./Images/Week-04/table-activities.JPG"  width="50%" height="100%">
