#!/bin/bash

# Wipe existing jobs to avoid conflicts
crontab -r

# dbt run
dbt_run="0 0 */2 * * docker run --env-file /home/circleci/.env --network=host --mount type=bind,source=/home/circleci/scopuli/ganymede/,target=/usr/app --mount type=bind,source=/home/circleci/scopuli/,target=/root/.dbt/ ghcr.io/dbt-labs/dbt-postgres:1.5.2 run --target prod"

# Create a temporary file to store the cron job entries
temp_file=$(mktemp)

echo "$dbt_run" >> "$temp_file"

# Load the temporary file as the new crontab
crontab "$temp_file"

# Remove the temporary file
rm "$temp_file"
