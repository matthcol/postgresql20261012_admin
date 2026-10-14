-- user postgres
-- database dbmovie

create user matth with
	login
	password 'password'
;

-- acces en lecture
grant usage on schema data to matth;
grant select on data.movie to matth;

revoke usage on schema data from matth; -- test ko pour user matth: select ne marche pas sans usage sur le schema
grant usage on schema data to matth;

alter user matth set search_path = data, public;

-- droit resumé "all tables": tables + vues
-- NB : non retroactif (à refaire à chaque nouvelle table ou vue)
grant select on all tables in schema data to matth;

select CURRENT_USER, CURRENT_SCHEMA, current_DATABASE();

-- roles implicites
create role r_reader;
grant usage on schema data to r_reader;
grant select on data.v_movie_latest to r_reader;
grant select on data.person to r_reader;

create user john with login password 'password';
create user jane with login password 'password';
alter user john set search_path = data, public;
alter user jane set search_path = data, public;

grant r_reader to john;
grant r_reader to jane;

create role r_contrib;
grant r_reader to r_contrib;
grant insert on data.v_movie_latest to r_contrib;
grant update (year, duration, director_id) on data.v_movie_latest  to r_contrib;
grant usage on sequence data.movie_id_seq to r_contrib; -- pour faire le 'insert'

create user alain  with login password 'password';
alter user alain set search_path = data, public;
grant r_contrib to alain;


-- apres avoir refait la vue v_movie_latest
grant select on data.v_movie_latest to r_reader;
grant insert on data.v_movie_latest to r_contrib;
grant update (year, duration, director_id) on data.v_movie_latest  to r_contrib;

-- Note: roles r_reader, r_contrib sont des roles implicites
-- john, jane, alain ont ses roles par défaut à leur connexion 
-- en fonction des grant respectifs

create role r_manager; -- role non implicite qd on l'accorde à qqn
grant usage on schema data to r_manager;
grant select, insert, update on all tables in schema data to r_manager;
grant usage on all sequences in schema data to r_manager;

create role r_reader_nh;
grant usage on schema data to r_reader_nh;
grant select  on data.movie, data.person to r_reader_nh;


-- drop user jacques;
create user jacques  with 
	login 
	password 'password'
	noinherit   -- ne prend aucun role accordé par défaut
;
alter user jacques set search_path = data, public;
grant r_manager, r_reader_nh to jacques;






























