This is the open source stacki-docker pallet for Stacki based systems. There's noting to pay for here. It's free, as in beer, and free as in your nethers when skinny-dipping. Enjoy.

StackIQ creates application pallets in phases. Phase 1 means an application will run correctly at it's basic usuable level and will be available upon installaction. Generally, there is little if any in the way of security; it's likely to follow the application's simple case documentation. We did that in Phase 1. If you want that, you can check out the 1.13.0 tag but it contains only Docker software, before they created the Community Edition which was, like, last week.

Phase 2 means the application will install on first installation of a set of machines securely, working for more complex cases and examples, and more flexible. It's probably production ready. It's more, it's better, but it probably needs some further work to make it more flexible for your use case.

Phase 3 will definitely be production ready, will allow for greater security and flexibility; however, that flexibility will require you do more stuff to get it the way you want it. Phase 3 for stacki-docker will likely be done on stacki 4.0 which will be out in about a month.

All that being said, this is phase2 of the docker pallet. It runs Docker Community Edition (17.03.0), has docker swarm mode baked in (installs and validates it automatically thankyouverymuch) and it TLS protected. If you are interested in just Docker and Docker Swarm Mode, this is the pallet and the instructions you should follow.

*** Warning: Don't do any of this if you are using stacki-docker
with the stacki-kubernetes pallet. Just follow those docs and you'll
be good. ***

This is the tl;dr. It's actually kinda long for a tl;dr but it's shorter than the full set of instructions in which I give you far more details than you want.

<h3>tl;dr</h3>

Do the following on the stacki frontend, unless it says "do this on the backend nodes." 

Download isos:
```
# cd /export
# mkdir isos
# cd isos
# wget https://s3.amazonaws.com/stacki/public/os/centos/7/CentOS-7-x86_64-Everything-1611.iso
# wget https://s3.amazonaws.com/stacki/public/os/centos/7/CentOS-Updates-7.3-7.x.x86_64.disk1.iso
# wget https://s3.amazonaws.com/stacki/public/pallets/3.2/open-source/stacki-docker-17.03.0-3.2_phase2.x86_64.disk1.iso

If you want monitoring:
# wget https://s3.amazonaws.com/stacki/public/pallets/3.2/open-source/stacki-prometheus-1.0-7.x.x86_64.disk1.iso
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
http://frontend.IP:9090 for prometheus
http://frontendIP.IP:3000 for grafana

<h3>Detailed Explanation</h3>
