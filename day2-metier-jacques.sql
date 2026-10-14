 select session_user, current_user, current_role; -- jacques, jacques, jacques si rien de precisé à la connexion


 select count(*) from movie; -- KO
 
 set role r_manager; -- on prend le role dont on n'a pas hérité par defaut mais dont on est membre
 select session_user, current_user, current_role; -- jacques, r_manager, r_manager
 select count(*) from movie;  -- OK
 insert into movie (title, year) values ('le futur', 2048); -- OK

set role r_reader_nh;
select session_user, current_user, current_role; -- jacques, r_reader_nh, r_reader_nh
select count(*) from movie;  -- OK
insert into movie (title, year) values ('le futur 2', 2050); -- KO

reset role; -- je redeviens Jacques sans casquettes

-- Note:
-- le role peut être precisé:
-- * en cours de session (set role, reset role)
-- * à la connexion (PgAdmin)
-- Pour psql faire connexion jacques puis set role


set role r_manager;
call add_movie(p_title =>'Heart of the Beast', p_year => 2026::smallint, p_director_name => 'David Ayer');
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