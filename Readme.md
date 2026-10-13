# PostgreSQL Administration

## Installation
### Windows
Installer EDB
### Linux
Installer le repository postgresql qui permet d'avoir les 5 dernières versions

```
systemctl status postgresql@18-main
pg_lsclusters
pg_ctlcluster 18 main start|stop
```
### Docker
Image officielle: postgres

### Client
- CLI : psql
    ```
    psql -U postgres -d postgres           # default port 5432, default host localhost
    psql -U postgres -d postgres -p 5433
    ```

    Linux : admin CLI avec user OS postgres
    ```
    sudo su - postgres
    psql
    ```

    Commandes psql
    ```
    \l   -- liste des bases
    \d   -- liste des 'tables'
    ```

- GUI : pgadmin4


### Diagnostique Réseau
Widows
```
netstat -ano | findstr LISTEN
```

Linux
```
netstat -plantu | grep LISTEN
ss -plantu | grep LISTEN
```

### Configuration réseau
- Fichier postgresql.conf : port + listen_address
=> restart via le service ou pg_ctlcluster/pg_ctl
- Fichier pg_hba.conf : filtrage réseau
=> reload via pg_ctlcluster/pg_ctl ou en interne : `select pg_reload_conf();`

### User / Password
```
alter user postgres password 'password';
```

## Base métier
Jouer un fichier SQL en CLI
```shell
# user umovie
psql -U umovie -d postgres -h 127.0.0.1 -p 5433 < 01-tables.sql 
psql -U umovie -d postgres -h 127.0.0.1 -p 5433 -f 01-tables.sql
# user postgres
psql -U postgres -d postgres  -f 01-tables.sql 



