-- user umovie
-- database: dbmovie

-- NB: umovie est un user métier propriétaire de la data mais aucun privilège DBA

create role moviemngr;
-- ERROR:  permission denied to create role
-- Only roles with the CREATEROLE attribute may create roles. 

-- ---------------------------------
-- Utilisation des tables métiers :
-- ---------------------------------

show search_path;  -- data, public (dernière version, settings fait par le DBA ou soit même)
select count(*) from movie;
select * from movie where year = 2026;

insert into movie (title, year) values ('Resident Evil', 2026); -- id auto de la sequence movie_id_seq
select * from movie where year = 2026; -- id = 8079249
select currval('movie_id_seq'); -- 8079249

-- session parallèle obtient le numero 8079250
select nextval('movie_id_seq'); -- 8079251

-- setval permet de reinitialiser le numéro

-- automatisation de la generation de PK
--  * default nextval('movie_id_seq'::regclass)
--  * type "serial" => create sequence + clause default
--  *    smallserial => type smallint : ~32K (millier)
--  *    serial      => type int      : ~2G (milliard)
--  *    bigserial   => type bigint   : ~9E (milliard de milliard)

create sequence my_seq; -- à utiliser coté applicatif

-- alternative à SERIAL : clause IDENTITY du standard SQL
-- https://www.postgresql.org/docs/18/ddl-identity-columns.html






