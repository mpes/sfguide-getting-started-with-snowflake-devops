use role securityadmin;
create or replace role cicd_role;
grant role cicd_role to role sysadmin; 

use role accountadmin;
grant CREATE INTEGRATION on account to role cicd_role;
use role sysadmin;
grant CREATE WAREHOUSE on account to role cicd_role;
grant CREATE database on account to role cicd_role;
use role cicd_role;

CREATE OR ALTER WAREHOUSE QUICKSTART_WH 
  WAREHOUSE_SIZE = XSMALL 
  AUTO_SUSPEND = 300 
  AUTO_RESUME= TRUE;
-- Separate database for git repository
CREATE OR ALTER DATABASE QUICKSTART_COMMON;

CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/mpes')
  ENABLED = TRUE;

CREATE OR REPLACE GIT REPOSITORY quickstart_common.public.quickstart_repo
  API_INTEGRATION = git_api_integration
  ORIGIN = 'https://github.com/mpes/sfguide-getting-started-with-snowflake-devops';


CREATE OR ALTER DATABASE QUICKSTART_PROD;
-- To monitor data pipeline's completion
CREATE OR REPLACE NOTIFICATION INTEGRATION email_integration
  TYPE=EMAIL
  ENABLED=TRUE;
-- Database level objects
CREATE OR ALTER SCHEMA bronze;
CREATE OR ALTER SCHEMA silver;
CREATE OR ALTER SCHEMA gold;
-- Schema level objects
CREATE OR REPLACE FILE FORMAT bronze.json_format TYPE = 'json';
CREATE OR ALTER STAGE bronze.raw;

-- ls @quickstart_common.public.quickstart_repo/branches/main/data/;
-- Copy file from GitHub to internal stage
copy files into @bronze.raw from @quickstart_common.public.quickstart_repo/branches/main/data/airport_list.json;
ls @bronze.raw;
