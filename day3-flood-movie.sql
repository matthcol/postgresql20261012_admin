-- Script de FLOOD de la table movie (dbmovie), version PL/pgSQL
-- ATTENTION : script généré mais NON exécuté/appliqué.
-- A relire puis lancer manuellement selon le besoin, ex:
--   call flood_movie(1, 1000000);
--   call flood_movie(1, 102345555, p_year => 2026, p_batch_commit => 10000);
--
-- Objectif : créer en boucle des films nommés Rambo_<n> (ex: Rambo_1 .. Rambo_<p_end>)
-- pour tester le comportement de la table movie sous forte volumétrie.
--
-- Rappel contraintes table movie (01-tables.sql) :
--   - title varchar(300) not null
--   - year  smallint     not null, CHECK(year >= 1850)
--   - UNIQUE(title, year)  -> title étant toujours différent (Rambo_<n>), pas de collision possible
--
-- Pourquoi une PROCEDURE (et pas une fonction ni un simple DO) :
-- une PROCEDURE appelée via CALL peut faire des COMMIT intermédiaires
-- (impossible dans un DO block ou une fonction), ce qui évite de garder
-- des dizaines/centaines de millions de lignes dans une seule transaction
-- (bloat, verrous, usage mémoire) lors d'un flood massif.

create or replace procedure flood_movie(
    p_start         int,
    p_end           int,
    p_year          smallint default 2026,
    p_batch_commit  int      default 1000
)
    language plpgsql
as $$
declare
    n int;
begin
    for n in p_start..p_end loop

        insert into movie(title, year) values ('Rambo_' || n, p_year);

        if n % p_batch_commit = 0 then
            commit;
            raise notice 'Inséré jusqu''à Rambo_%', n;
        end if;

    end loop;

    commit; -- flush du dernier lot partiel (< p_batch_commit lignes)

    raise notice 'Flood terminé: % films créés (Rambo_% .. Rambo_%)', p_end - p_start + 1, p_start, p_end;
end;
$$;

-- exemples d'appel :
-- call flood_movie(1, 1000);                                  -- petit flood de test
-- call flood_movie(1, 1000000);                                -- 1 million de films, commit tous les 1000
-- call flood_movie(1, 102345555, p_batch_commit => 10000);     -- flood massif, commit tous les 10000
