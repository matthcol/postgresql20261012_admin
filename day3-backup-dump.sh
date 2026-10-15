
# Documentation: https://www.postgresql.org/docs/18/backup.html

# DUMP
# - pg_dump : 1 base
# - pg_dumpall : transverse (users)
# - COPY vs \copy

# DUMP par défaut : à rejouer par psql
# * format p (plain) : en langage "SQL" (+ psql)
# * contenu : DDL + data 
# * DDL = (SQL) Data Definition Language : table, vues, index, sequence, contraintes, ...
pg_dump -U umovie -d dbmovie -h localhost -p 5433 -f dbmovie.dump
pg_dump -U postgres -d dbmovie -h localhost -p 5433 -f dbmovie_dba.dump

# * format custom (c): binaire + compression
pg_dump -U umovie -d dbmovie -h localhost -p 5433 -F c -f dbmovie_custom.dump
pg_dump -U umovie -d dbmovie -h localhost -p 5433 -F c -Z gzip:1 -f dbmovie_custom.dump.1.gz
pg_dump -U umovie -d dbmovie -h localhost -p 5433 -F c -Z gzip:9 -f dbmovie_custom.dump.9.gz
pg_dump -U umovie -d dbmovie -h localhost -p 5433 -F c -Z none | 7z a -si dbmovie_custom.dump.7z

# * formats t et d (directory)
# directory : DDL + table des matieres + 1 fichier archive par table
pg_dump -U umovie -d dbmovie -h localhost -p 5433 -F d -f dbmovie_dir_dump
tree dbmovie_dir_dump/
# tar : idem que directory mais non compressé
pg_dump -U umovie -d dbmovie -h localhost -p 5433 -F t -f dbmovie.dump.tar  # à compresser

# Rejouer le dump  sur une base aux caracatérostiques communes
# creer la base cible à l'identique (ici même serveur)
psql -U postgres
    create database dbmovie_test encoding 'UTF-8';
    \l
psql -U  umovie -d dbmovie_test -h localhost -p 5433 -f dbmovie.dump # echec sur la creation du schema
psql -U  postgres -d dbmovie_test -h localhost -p 5433 -f dbmovie.dump # OK
# checkup
psql -U  umovie -d dbmovie_test -h localhost -p 5433
     \d
     select count(*) from movie;
     insert into movie(title, year) values ('Primetime', 2026) returning id; -- 8079265

# REjouer le dump sur un cluster neuf
pg_createcluster 18 main_clone --port 5436
pg_lsclusters
pg_ctlcluster 18 main_clone start
psql -U postgres
    create database dbmovie_clone encoding 'UTF-8';
    \l
psql -U  postgres -d dbmovie_clone -p 5436 -f dbmovie.dump -- ok pour la data mais wrong owner, privileges user tiers
psql -U  postgres -d postgres -p 5436
    drop database dbmovie_clone;
    create database dbmovie_clone encoding 'UTF-8';
    \l

# dump des users de la base dbmovie
pg_dumpall -U postgres -p 5433 -r -f roles.dump
# recreer les users sur la base cible (+ modif user postgres)
psql -U postgres -p 5436 -f roles.dump 
# reimporter la base (avec tous les users)
psql -U  postgres -d dbmovie_clone -p 5436 -f dbmovie.dump
# checkup avec user metier proprio
psql -U  umovie -d dbmovie_clone -h localhost -p 5436
    \d
    select count(*) from movie;

pg_dump -U  umovie -d dbmovie -h localhost -p 5433 -t data.movie -f movie.dmp
pg_dump -U  umovie -d dbmovie -h localhost -p 5433 -t data.movie -s -f movie.ddl.dmp
pg_dump -U  umovie -d dbmovie -h localhost -p 5433 -t data.movie -a -f movie.data.dmp
pg_dump -U  umovie -d dbmovie -h localhost -p 5433 -t data.movie -a --inserts -f movie.data.i.dmp

# NB: un dump en plain text est editable (à utiliser avec precaution) car pas de remap en postgresql

# rejouer un dump dans un format non plain
pg_restore -U postgres -d dbmovie_preprod -p 5433 dbmovie_custom.dump
psql -U umovie -d dbmovie_preprod -h localhost -p 5433
    \d
    select count(*) from movie;

# COPY vs \copy
# - COPY avec data interne
# - COPY avec fichier externe (export/import) : limité au côté serveur + droits OS 
# - \copy avec fichier externe (export/import) : côté client ou server

# DEMO Windows => Server DB Ubuntu
# Export
psql -U umovie -d dbmovie -h localhost -p 5433
    \copy movie to 'movie.tsv';   -- export TSV,  encoding client 
    \copy person to 'person.tsv'; -- export TSV,  encoding client (ici Windows 1252)
    SET client_encoding = 'UTF8';
    show client_encoding;
    \copy person to 'person.utf8.tsv'; -- export TSV,  encoding client réglé juste avant = UTF8
    \copy person to 'person.csv' delimiter ',' CSV HEADER  ENCODING 'UTF-8';
    \copy person to 'person.fr.csv' delimiter ';' CSV HEADER  ENCODING 'WIN1252';
    \copy (select id, title, year, duration, director_id from movie where year = 2026) to movies_2026.tsv
    \copy (select id, title, year, duration, director_id from movie where year = 2026) to movies_2026.fr.csv with (delimiter E';', format csv, header, encoding 'WIN1252');
    \copy play to 'play.utf8.tsv' with (HEADER,   ENCODING 'UTF-8');

# Import
psql -U umovie -d dbmovie -h localhost -p 5433
    truncate play;
    select count(*) from play; -- 0
    \copy play from 'play.utf8.tsv' with (HEADER,   ENCODING 'UTF-8');
    \copy movie(id, title, year, duration, director_id) from 'movie2026.utf8.tsv' with (HEADER,   ENCODING 'UTF-8');

# File System
# n'importe quel outil de sauvegarde OS, INFRA : à froid, copie du répértoire PGDATA
pg_lsclusters
pg_ctlcluster 18 main_clone stop
pg_lsclusters
cd /var/lib/postgresql/18
tar cvzf /BackupPg/dbmovie_clone.tgz main_clone/    # backup de la nuit
pg_ctlcluster 18 main_clone start
# corrompre la donnée au niveau base ou OS
pg_ctlcluster 18 main_clone stop
mv main_clone/ main_clone_corrupted
tar xvzf /BackupPg/dbmovie_clone.tgz 
ls -al main_clone  # check owner + droits
pg_ctlcluster 18 main_clone start

# Basebackup et PITR
# * basebackup à chaud comme en mode cluster avec un mirroir
#     - wal_level = replica (défaut)
#     - max_wal_senders > 0 (10 défaut)

# Exemple avec destination: -D dbmovie_backup_replica
pg_basebackup -U postgres  -p 5433 -D dbmovie_backup_replica
