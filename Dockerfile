FROM postgres

COPY tables.sql /docker-entrypoint-initdb.d/00_tables.sql
COPY functions /functions
RUN cat functions/*.sql > /docker-entrypoint-initdb.d/01_functions.sql
COPY seed-data.sql /docker-entrypoint-initdb.d/02_seed_data.sql
