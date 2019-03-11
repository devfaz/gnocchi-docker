#!/bin/sh -x
printf "[indexer]\nurl = postgresql://${POSTGRESQL_USER}:${POSTGRESQL_PASSWORD}@indexer/postgres\n" > /etc/gnocchi/gnocchi.conf
printf "[storage]\ncoordination_url = redis://:${REDIS_PASSWORD}@storage\n" >> /etc/gnocchi/gnocchi.conf
printf "[incoming]\ndriver = redis\nredis_url = redis://:${REDIS_PASSWORD}@storage\n" >> /etc/gnocchi/gnocchi.conf
crudini --set /etc/gnocchi/gnocchi.conf api uwsgi_mode http-socket
crudini --set /etc/gnocchi/gnocchi.conf api enable_proxy_headers_parsing true
#crudini --set /etc/gnocchi/gnocchi.conf DEFAULT debug true
#crudini --set /etc/gnocchi/gnocchi.conf metricd greedy false

# NOTE(sileht): To get Gnocchi version build log
pip freeze | grep gnocchi

gnocchi-upgrade || true

case $1 in
    metricd)
        exec gnocchi-metricd
        ;;
    api)
        exec uwsgi /etc/gnocchi/uwsgi.ini
        ;;
    stats)
        exec gnocchi-statsd
        ;;
esac
