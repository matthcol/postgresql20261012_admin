-- user : umovie
-- database : dbmovie

show search_path;

-- note : creation de la table apres avoir donné les droits de lecture
-- à l'utilisateur matth sur toutes les tables du schema data
create table write(
	writer_id int not null,
	movie_id int not null,
	constraint pk_write primary key(writer_id, movie_id)
);

-- drop view v_movie_latest;
create view v_movie_latest as (
	select id, title, year, duration, director_id
	from movie
	where year >= extract(year from current_date) - 10
);

select * from v_movie_latest order by year;

select * from person where name ilike 'chris% nolan'; -- 634240

select * from movie where title ilike 'west side%';
select * from movie where title ilike 'spider%';

-- securiser la vue en modification
drop view v_movie_latest;
create view v_movie_latest as (
	select id, title, year, duration, director_id
	from movie
	where year >= extract(year from current_date) - 10
) with check option;


select * from movie where title ilike 'gone with%';


-- code stocké : voir autre script pour aujouter le code stocké
-- tests:

insert into movie (title, year) values ('Avengers: Doomsday', 2026);
-- avec 1 autre user: insert into v_movie_latest (title, year) values ('Dune: Part 3', 2026);

select id, title, year, duration, director_id, last_update, update_by
from movie
where year >= 2026
;

insert into v_movie_latest (title, year) values ('Dune: Part 3', 2026);

select 
	id, title, year, 
	fn_format_duration(duration) as duration_hm, 
	director_id, last_update, update_by
from movie
where year >= 2026
;


call add_movie(p_title =>'Normal', p_year => 2025::smallint, p_director_name => 'Ben Wheatley'); --ko avec notice
insert into person(name, birthdate) values ('Ben Wheatley', NULL);
call add_movie(p_title =>'Normal', p_year => 2025::smallint, p_director_name => 'Ben Wheatley'); --ok

call add_movie(p_title =>'Un film', p_year => 2026::smallint, p_director_name => 'Steve McQueen');
-- NOTICE:  Plusieurs personnes nommees "Steve McQueen" trouvees :
-- NOTICE:    id = 537, birthdate = 1930-03-24
-- NOTICE:    id = 2588606, birthdate = 1969-10-09


-- RECAP code stocké
-- * types
-- * operator : +, -, ...
-- * function
-- * procedure
-- * trigger
-- 
-- NB: si schema à part, search_path = data, stored_proc, public


-- *******************************************************************
--                       I N D E X E S
-- *******************************************************************

select * from pg_indexes where schemaname = 'data';
-- indexes implicites :
-- *  sur la contrainte UNIQUE (PRIMARY KEY) 
-- * nom de l'index = nom de la contrainte

-- Exemple : 
--    pk_movie avec les caractéristiques : UNIQUE, BTREE

select 
	id, title, year
from movie
where year = 2026;

select 
	id, title, year
from movie
where id = 8079252;

select 
	id, title, year
from movie
where duration >= 180
;


alter table movie drop constraint uniq_movie;

create index idx_movie_year on movie(year); -- default: btree
select * from pg_indexes where schemaname = 'data';

select 
	id, title, year
from movie
where year = 1984
;  -- utilise explain et explain analyze pour voir l'efficacité des indexes

-- IMDB
select 2026 - 1888 + 1; -- 139
select 15_000_000 / (2026 - 1888 + 1); -- sur imdb ~ 100K oeuvres par an

-- ICI
select 
	count(distinct year) as nb_years, -- 110
	count(*) as nb_movie, -- 1196
	count(*)::decimal / count(distinct year) as nb_movie_by_year, -- 10.8727272727272727
	count(*)::decimal / count(distinct title) as nb_movie_by_title -- 1.003 : quasi unique
from movie;

select * 
from pg_stats 
where schemaname = 'data'
order by tablename;

-- stat n_distinct pour l'efficacité d'un index btree
--  * < 0 : abs(n_distinct) = count(distinct colonne) / count(colonne) = selectivité
--  * > 0 : n_distinct = count(distinct colonne)

-- stats automatiques sur un échantillon  (cf postgresql.conf)
-- tuning possible par base, table, colonne


select * from pg_stat_user_tables;  -- ou pg_stat_all_tables + filtre schema

select
	relname,
	last_analyze,
	last_autoanalyze,
	last_vacuum,
	last_autovacuum
from pg_stat_user_tables;

show autovacuum;

analyze movie; -- owner ou dba
select
	relname,
	last_analyze,  -- MAJ
	last_autoanalyze,
	last_vacuum,
	last_autovacuum
from pg_stat_user_tables;

vacuum movie;
select
	relname,
	last_analyze,  
	last_autoanalyze,
	last_vacuum,  -- MAJ
	last_autovacuum
from pg_stat_user_tables;

vacuum analyze movie;
select
	relname,
	last_analyze, -- MAJ 
	last_autoanalyze,
	last_vacuum,  -- MAJ
	last_autovacuum
from pg_stat_user_tables;


-- settings generaux à tuner dans postgresql.conf
-- tunning au cas par cas sur chaque table : SQL
select * 
from pg_settings
where
	name like 'autovacuum%'
	or name = 'track_counts'
;

select count(*) from play; -- 66547
delete from play where actor_id % 2 = 1;  -- DELETE 32963

-- 1 mn apres maximum (naptime) => auto analyze + vacuum car les seuils ont été dépassés
select
	relname,
	last_analyze, 
	last_autoanalyze,
	last_vacuum,  
	last_autovacuum
from pg_stat_user_tables;


select * from pg_database; -- oid = nom répertoire base
	-- 1 = template 1
	-- 4 = template 0
	-- 5 = postgres
	-- 16447 = dbmovie

select * from pg_tables;
select * from pg_class where relname in ('movie', 'play');
	





