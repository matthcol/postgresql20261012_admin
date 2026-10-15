select * from pg_database;

-- vues de definition
select * from pg_tables;
select * from pg_indexes;
select * from pg_sequences;

-- vue de stockage
select * from pg_class;
select * from pg_class where relname like '%_seq';
select * from pg_class where relname in ('play', 'movie');
select distinct relkind from pg_class;
select * from pg_class where relkind = 't';
-- v : view
-- i : index
-- r : ordinary table (relation)
-- S : sequence
-- t : toast table
-- ...
-- https://www.postgresql.org/docs/18/catalog-pg-class.html

select * from pg_namespace where nspname = 'data';
select * from pg_authid where rolname = 'umovie';

select * 
from pg_class 
where relnamespace = (select oid from pg_namespace where nspname = 'data')
;

select * 
from pg_class 
where relowner = (select oid from pg_authid where rolname = 'umovie')
;

select 
	oid,
	relname,
	relnamespace,
	relowner,
	relfilenode,
	relkind
from pg_class 
where relnamespace = (select oid from pg_namespace where nspname = 'data')
order by relkind
;

-- table
vacuum full data.play;

-- base
vacuum full;


-- AUTO régulierement (ou manuel)
-- cartographie seule (FSM)
vacuum data.play;
-- stats seule
analyze data.play;
-- cartographie + stats
vacuum analyze data.play;

-- MANUEL
vacuum full;
vacuum full analyze;

-- WAL
show wal_segment_size; -- 16 MB (creation du cluster, initdb)
show min_wal_size; -- 80 MB  : postgresql.conf
show max_wal_size; -- 1  GB   : postgresql.conf

-- Purge auto
--  * si replica : WAL purgé ou recyclé si le WAL est synchro avec les replicas
--  * si archivage : WAL purgé ou recyclé si le WAL est archivé
--  * sinon : WAL purgé ou recyclé si les ecritures du WAL sont bien effectives sur disque

---------------------------------
--  Users, sesssions et verrous
---------------------------------


-- sessions
select * from pg_stat_activity 
where datname is not null
order by usename;

select pg_cancel_backend(9169);
select pg_terminate_backend(9169);
select pg_terminate_backend(8050);

-- verrous des transactions
select * from pg_locks;
select * from pg_class where relname = 'movie'; -- oid = "16574"
select * from pg_locks where relation = 16574;


-- Ouvertures :
-- * extension : postgis, pg_stat_statements
select * from pg_available_extensions order by name;

-- * stats au niveau query :  pg_stat_statements (audit des queries)











