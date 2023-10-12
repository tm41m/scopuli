IMPORT FOREIGN SCHEMA public
    LIMIT TO (statcan_cpi_monthly)
    FROM SERVER aethervest_prod_server
    INTO aethervest_src;
