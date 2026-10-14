select title, year from data.movie limit 10;
-- sans usage sur le schema data:
-- ERROR:  permission denied for schema data

-- sans grant select sur la table
-- ERROR:  permission denied for table movie

 select title, year from movie limit 10;
 -- ERROR:  relation "movie" does not exist

 -- OK with search_path custom

-- nouvelle table, bien avoir rejoué le grant on all tables
select count(*) from write;