COPY mart_orders TO 'data/processed/mart_orders.csv'
(HEADER, DELIMITER ',');

COPY mart_sales TO 'data/processed/mart_sales.csv'
(HEADER, DELIMITER ',');