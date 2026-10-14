select * from v_movie_latest;  -- privilege r_reader inclus dans r_contrib
insert into v_movie_latest (title, year) values ('The Odyssey', 2026); -- id 8079249
select * from v_movie_latest order by year desc;

select * from person where name ilike 'chris% nolan';
update v_movie_latest set director_id = 634240 where id = 8079249;  -- OK
update v_movie_latest set title = 'oh oh oh' where id = 8079249;  -- ERREUR:  droit refusé pour la vue v_movie_latest

insert into v_movie_latest (title, year) 
    values ('Spider-man: Brand New Day', 2026)
    returning id; -- 8079250

select 
    m.title,
    m.year,
    d.name
from
    v_movie_latest m
    left join person d on m.director_id = d.id
order by m.year desc
;


select * from v_movie_latest where year < 2010;
insert into v_movie_latest (title, year) values ('West Side Story', 1961); -- ok avec la vue 1ere version
select * from v_movie_latest where year < 2010; -- le film ajouté n'est pas vue

update v_movie_latest set year = 1900 where id = 8079250; -- Spider-Man: Brand New Day de 2026 => 1900
-- ok avec la vue 1ere version
 select * from  v_movie_latest order by year desc; -- disparu


-- Avec la vue sécurisée (check option)

insert into v_movie_latest (title, year) values ('Gone With The Wind', 1939); 
-- ERROR:  new row violates check option for view "v_movie_latest"
-- DETAIL:  Failing row contains (title, year) = (Gone With The Wind, 1939).

update v_movie_latest set year = 1900 where id = 8079252; -- The Odyssey
-- ERROR:  new row violates check option for view "v_movie_latest"
-- DETAIL:  Failing row contains (year) = (1900).

select 
    m.title,
    m.year,
    m.duration,
    d.name
from
    v_movie_latest m
    left join person d on m.director_id = d.id
order by m.year desc
;

update v_movie_latest set duration = 172 where id = 8079252; --OK

select 
    session_user,
    current_user, current_role -- fonctions alias 
;

-- test code stocké
 insert into v_movie_latest (title, year) values ('Dune: Part 3', 2026); 
 select * from v_movie_latest order by year desc;


 select 
	id, title, year, 
	fn_format_duration(duration) as duration_hm, 
	director_id
from v_movie_latest
where year >= 2026
;

select fn_format_duration(172); -- KO: 172 est un int pas un smallint
select fn_format_duration(172::smallint);

call add_movie(p_title =>'Heart of the Beast', p_year => 2026::smallint, p_director_name => 'David Ayer');
-- ERROR:  permission denied for table movie
-- CONTEXT:  SQL statement "insert into movie(title, year, duration, synopsis, poster_uri, color, pg, director_id)
--    values (p_title, p_year, p_duration, p_synopsis, p_poster_uri, p_color, p_pg, v_director_id)
--    returning id"
