IMPORT FOREIGN SCHEMA public
    LIMIT TO (statcan_food_prices)
    FROM SERVER aethervest_prod_server
    INTO aethervest_src;
