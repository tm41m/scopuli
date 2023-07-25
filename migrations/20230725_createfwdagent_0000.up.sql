-- For more information on the hack, refer to the extension
-- documentation here - https://www.postgresql.org/docs/current/postgres-fdw.html

-- In order to cost-efficiently, somewhat artificially, create a separation of concerns
-- between the analytics layer and the extraction layer, we use postgres_fdw to define
-- a foreign schema from aethervest.public to scopuli_prod.aethervest_src

-- This can scale vertically later where the scopuli database is migrated to its independent
-- cluster

-- User creation is completed in aethervest since the cluster is shared at the moment

-- CREATE USER scopuli WITH PASSWORD '${SCOPULI_PG_PASSWORD}';

-- GRANT USAGE ON DATABASE aethervest TO scopuli;

-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO scopuli;

CREATE EXTENSION postgres_fdw;

CREATE SERVER aethervest_prod_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host '${AETHERVEST_PROD_PG_HOST}', port '${AETHERVEST_PROD_PG_PORT}', dbname '${AETHERVEST_PROD_DBNAME}')
;

GRANT USAGE ON FOREIGN SERVER aethervest_prod_server to scopuli;

CREATE USER MAPPING FOR scopuli
    SERVER aethervest_prod_server
    OPTIONS (user '${SCOPULI_PROD_PG_HOST}', '${SCOPU_PROD_PG_PASSWOD}')
;

CREATE SCHEMA aethervest_src;

GRANT USAGE ON SCHEMA aethervest_src to scopuli;

IMPORT FOREIGN SCHEMA public
    FROM SERVER aethervest_prod_server
    INTO aethervest_src
;
