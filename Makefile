prod-db-shell:
	PGPASSWORD=${SCOPULI_PROD_PG_PASSWORD} \
	psql -U ${SCOPULI_PROD_PG_USERNAME} -h ${SCOPULI_PROD_PG_HOST} \
	-p ${SCOPULI_PROD_PG_PORT} -d ${SCOPULI_PROD_PG_DBNAME}
