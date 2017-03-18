This is phase2 of the docker pallet.

** Warning: Don't do any of this if you are using stacki-docker
with the stacki-kubernetes pallet. Just follow those docs and you'll
be good. **

<h3>tl;dr</h3>

Download isos:
```
# cd /export
# mkdir isos
# cd isos
# wget yeahimmagettalistforyourealsoon.
```

Add/enable/disable pallets:
```
# stack add pallet *.iso
# stack list pallet
# stack disable pallet os
# stack enable pallet CentOS CentOS-Updates stacki-docker stacki-prometheus
```

You need the global spreadsheets:
```
# yum clean all
# yum install stacki-docker-spreadsheets
cd /export/stack/spreadsheets/examples
cat global-docker-attrs-swarm.csv 
```

Change the master ip info. the 10.1.255.254 should be the ip of
whatever your docker swarm master will be.

Swarm is default enabled. Don't run the pallet if you're using
kubernetes.

demo is default enabled. Set it to false if you don't want a whole
bunch of containers right off the bat.

Load the gloabl attrs:
```
stack load attrfile file=global-docker-attrs-swarm-global.csv 
```

Run the pallet:
```
stack run pallet stacki-docker | bash
```

It worked if the listener is listening:
```
systemctl status stacki-listener
```

Now add hosts. You have a hosts file right?
```
# stack load hostfile file=hosts.csv
```

Now prep a host spreadsheet. Add your hosts.
```
# stack load hostfile file=hosts.csv 
```

Adapt the /export/stack/spreadsheets/example/host-docker-swarm.csv
with your hosts and the settings.
If you want detailed info on settings, see below.
You're the one following the tl;dr. Suck it up cowboy.
```
# stack load attrfile file=host-docker-swarm.csv
```

Add partitions. This works for me. You may want to do something else.
The "mkfsoptions" is a requirement for whatever you put it on.
```
# stack load storage partition file=docker-partitions.csv 
```

If you want monitoring, use the stacki-prometheus pallet, AFTER
you've done everything above.
```
stack run pallet stacki-prometheus | bash
systemctl status sflow-rt
```

Install your hosts:
```
# stack set host boot backend action=install
# stack set host attr backend attr=nukedisks value=true
```

Now power cycle. When they come up, if you've used stacki prometheus,
you'll have access at: 
http://<frontendIP>:9090 for prometheus
http://<frontendIP>:3000 for grafana
http://<frontendIP>:8008 for sflow-rt

<h3>Detailed Explanation</h3>
