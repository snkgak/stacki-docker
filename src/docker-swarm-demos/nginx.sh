docker service create \
--replicas 3 \
--name="slothweb" \
--network container-net \
nginx
