# Contributing

## Configuring the Environment

This guide was written for `python 3.8.0`. To set up a local environment for this project and have source (`src`) mirror production state, you will have to:

1. Create a virtual environment in the root folder of the project with `python3 -m venv venv`. Activate the environment with `source venv/bin/activate` and `pip install dbt-core==1.5.2`.

2. Ask the admin @tm41m for credentials to your personal postgres development database and have your ip whitelisted to access the VPC network.

3. Copy the `env.sample` file into a new file called `env.local` and replace the variable's values with your personal credentials. Run `source .env.local`.

4. Paste the `profiles.yml` to `~/.dbt/`

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
