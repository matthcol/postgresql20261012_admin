-- table : OK car owner
vacuum full play;

-- ok sur les objets dont on est propriétaire
-- ko sur les autres
vacuum full; 


select * from movie where year = 2026;


select * from person where name like 'Ren%';

call flood_movie(1, 10_000, 2026::smallint);
select count(*) from movie where title like 'Rambo%' and year = 2026;
call flood_movie(1, 500_000, 2027::smallint);
select count(*) from movie where title like 'Rambo%' and year = 2027;


select * 
from person 
where name ~* '^ren[eé].*'
order by name;  
-- ordre des caracteres technique (collation par défaut)
-- ici: C.UTF8 fournie par libc : rene w... < rené b...

select * from pg_database;  -- pour voir la collation par defaut

-- collations ICU fournies par PostgreSQL au lieu de l'OS

select * 
from person 
where name ~* '^ren[eé].*'
order by name collate "fr-FR-x-icu";  

CREATE COLLATION "fr-FR-UTF8" (
    provider = libc,
    locale = 'fr-FR.UTF-8'  -- ancien style, lié à win1252, pas UTF8
);


select * from pg_collation where collname like 'fr%';

-- reglage de la collation:
-- * niveau cluster
-- * niveau base + repartir éventuellement du template 0
-- * niveau table / colonne
-- * niveau query
-- 2 providers : libc (old, dept OS) ou icu (new, independant OS)


-- example de transaction 
-- * mode par defaut de postgres = pas en transaction : 1 ordre DML = validation directe
-- * mode transaction avec plusieurs ordres DML : transaction explicite

select * from movie where title like 'The Odyss%'; -- 8079252
begin; -- debut de transaction
update movie set duration = 173 where id = 8079252;
select * from movie where id = 8079252;
-- TODO : autres ordres DML
commit; -- fin transaction OK
-- rollback;  -- ou fin transaction KO, annule tout

-- Faire en //, d'autres session et voir les pg_locks sur les tables
















