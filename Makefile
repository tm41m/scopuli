prod-db-shell:
	PGPASSWORD=${SCOPULI_PROD_PG_PASSWORD} \
	psql -U ${SCOPULI_PROD_PG_USERNAME} -h ${SCOPULI_PROD_PG_HOST} \
	-p ${SCOPULI_PROD_PG_PORT} -d ${SCOPULI_PROD_PG_DBNAME}

local-db-shell:
	PGPASSWORD=${SCOPULI_LOCAL_PG_PASSWORD} \
	psql -U ${SCOPULI_LOCAL_PG_USERNAME} -h ${SCOPULI_LOCAL_PG_HOST} \
	-p ${SCOPULI_LOCAL_PG_PORT} -d ${SCOPULI_LOCAL_PG_DBNAME}

bootstrap-runner-prod-remote: scripts/bootstrap.sh
	export SCOPULI_RUNNER_SSH_KEY=$(< "${SCOPULI_RUNNER_SSH_KEY_FILEPATH}")
	ssh -A -o StrictHostKeyChecking=no ${SCOPULI_RUNNER_PROD_HOST} \
		"export SCOPULI_RUNNER_DIR=${SCOPULI_RUNNER_DIR}; \
		 export SCOPULI_RUNNER_SSH_KEY=\"${SCOPULI_RUNNER_SSH_KEY}\"; \
		 export SCOPULI_RUNNER_PROD_HOST=${SCOPULI_RUNNER_PROD_HOST}; \
		 export SCOPULI_RUNNER_ENV=prod; \
		 bash -s" < scripts/bootstrap.sh

load-census-divisions:
	bash scripts/load_census_divisions.sh

load-commercial-salmon-data:
	bash scripts/load_commercial_salmon_data.sh

sqlfluff-fix:
	sqlfluff fix ganymede/

sqlfluff-lint:
	sqlfluff lint ganymede/
