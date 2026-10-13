-- user : postgres
-- database : postgres

select * from pg_database;
-- postgres : base de maintenance (base métier ou DBA only)
-- template0 et template1 : bases templates

select * from pg_roles; -- roles (role + user interactif)
select * from pg_user;  -- users interactifs (can login true)
select * from pg_shadow; -- gestion des mots de passes internes (scram-sha-256, old md5)

-- Postgresql : user = role with login
create user umovie with   -- USER/ROLE : 2 mots clés interchangeables
	login
	password 'superpassword123'
;
drop user umovie;

create role moviefan;

show password_encryption; -- "scram-sha-256"
set password_encryption = md5;  -- modification pour cette session
show password_encryption;

-- creation user avec 1 password en md5
create user demo_md5 with
	login
	password 'password'
;  -- WARNING:  setting an MD5-encrypted password
select * from pg_shadow;
-- + settings hba.conf pour laisser passer demo_md5 en md5


-- changer le mot de passe de md5 en scram-sha-256
-- 1 - retirer la regle specifique md5 (ou changer md5 => scram-sha-256)
select pg_reload_conf();
-- 2 - renouveler tous les mots de passe
set password_encryption = "scram-sha-256";
show password_encryption;
alter user demo_md5 with password 'password';
select * from pg_shadow;


-- Creation Base métier + schema
CREATE DATABASE dbmovie ENCODING = 'UTF8'; -- NB: + owner, + locale
select * from pg_database;

-- changer de connexion 
-- 	 * avec menu déroulant de l'onglet courant de pgadmin
--   * [opt] creer une nouvelle connexion dans pgadmin
--   * avec psql : se reconnecter ou utiliser \c dbmovie (même user)
CREATE SCHEMA umovie
    AUTHORIZATION umovie;

-- ajouter les tables en CLI
-- psql -U umovie -d dbmovie -h 127.0.0.1 -p 5433 -f 01-tables.sql

show search_path;  -- "$user", public

-- Note : si tables créées avec postgres
alter table umovie.movie owner to umovie;
alter table umovie.person owner to umovie;
alter table umovie.play owner to umovie;
alter table umovie.have_genre owner to umovie;


drop schema umovie;  -- + cascade !!!
drop schema umovie cascade;

-- schema métier de nom different du user owner
create schema data authorization umovie;
-- drop schema data cascade;

alter user umovie set search_path = data, public;
select usename, useconfig from pg_user;

-- check with user umovie sur une connection dédiée
-- show search_path;

-- avec le user umovie install database
-- psql -U umovie -d dbmovie -h 127.0.0.1 -f 00-import-tables.sql 











