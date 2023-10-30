# Contributing

## Configuring the Environment

This guide was written for `python 3.8.0`. To set up a local environment for this project and have source (`*_src` schemas) mirror production state, you will have to:

1. Create a virtual environment in the root folder of the project with `python3 -m venv venv`. Activate the environment with `source venv/bin/activate` and `pip install dbt-core==1.5.2 dbt-postgres==1.5.2`.

2. Ask the admin @tm41m for credentials to your personal postgres development database and have your ip whitelisted to access the VPC network.

3. Create the file `.env.local` in the root directory of the project and copy the contents of `env.sample` file into it. Replace the variables with your personal credentials securely shared with you from the previous step. Run `source .env.local`.

4. Create the directory `~/.dbt/` if it does not exist already and copy `profiles.yml` into the folder. 

5. Run `dbt debug`, your output should look something like this - 

```
dbt debug --target local
19:17:28  Running with dbt=1.5.2
19:17:28  dbt version: 1.5.2
19:17:28  python version: 3.8.0
    ...
19:17:28  Configuration:
19:17:28    profiles.yml file [OK found and valid]
19:17:28    dbt_project.yml file [OK found and valid]
19:17:28  Required dependencies:
19:17:28   - git [OK found]

19:17:28  Connection:
19:17:28    host: xxxxx
19:17:28    port: xxxxx
19:17:28    user: xxxxx
19:17:28    database: xxxxx
19:17:28    schema: xxxxx
19:17:28    search_path: None
19:17:28    keepalives_idle: 0
19:17:28    sslmode: None
19:17:28  Registered adapter: postgres=1.5.2
19:17:28    Connection test: [OK connection ok]

19:17:28  All checks passed!
```

6. To debug further, you can try to shell into the postgres with `make local-db-shell`.

7. Create a file under `.git/hooks/pre-commit` and paste the script below:

```
#!/bin/bash

pre-commit

exit $?
```

To fix your linting complaints, run `make sqlfluff-fix`.

## Project Structure

```
scopuli
  |
  --> ganymede -- The dbt project for building analytics describing quality, cost of living and consumer prices.
        |
        --> models -- Transformations go here, there's another level of organization below
             |
             --> stahl (steel) -- This subdirectory contains formatted data without much aggregation. In other words, we store all transformations that clean the data so that it has necessary formats needed for the next level of transformation.
             |
             --> wolfram (tungstun) -- This subdirectory contains all transformations that are ready to be consumed by the end-users. As an heuristic, if an API can be pointed to this model, then it should go in this folder. 
        |
        --> macros -- Re-usable functions that can be called to compile blocks of sql
        |
        --> seeds -- Used for storing smaller tabular files that can be referenced as sources
        |
        --> snapshots -- SCD II state captures of objects defined in dbt go here 
        |
        --> tests -- Custom tests go here
  |
  --> migrations -- Migrations to be run against a postgres database to sync sources and seed the raw data

```
