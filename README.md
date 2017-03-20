<h1>Stacki Docker Pallet</h1>

This is the open source stacki-docker pallet for Stacki based systems. There's noting to pay for here. It's free, as in beer, and free, as in your nethers when skinny-dipping. Enjoy. (Either Docker or skinny-dipping. Tell us about the first, not the second.)

StackIQ creates application pallets in phases. Phase 1 means an application will run correctly at its basic usuable level and will be available upon installation. Generally, there is little, if any, in the way of security; it's likely to follow the application's simple case documentation. We did that in Phase 1. If you want that, you can check out the 1.13.0 tag but it contains only Docker software, before they created the Community Edition which was, like, last week.

Phase 2 means the application will install on first installation on a set of machines securely, working for more complex cases and examples, and more flexible. It's probably production ready. It's more, it's better, but it probably needs some further work to make it more flexible for your use case.

Phase 3 will definitely be production ready, will allow for greater security and flexibility; however, that flexibility will require you do more stuff to get it the way you want it. Phase 3 for stacki-docker will likely be done on stacki 4.0 which will be out in about a month.

All that being said, this is phase2 of the docker pallet. It runs Docker Community Edition (17.03.0), has docker swarm mode baked in (installs and configure swarm mode automatically thankyouverymuch) and is TLS protected. If you are interested in just Docker and Docker Swarm Mode, this is the pallet and the instructions you should follow.

Please note, we assume either your frontend or your backend nodes have access to the internet. This will work for a local docker registry, but I haven't tested that yet so I'm not going to give those instructions.

If your frontend has internet access, we'll open the firewall so the backend nodes can get the images they need for the demo.

If you don't need to run the demo, then you don't have to open the firewall. 

*** Warning: Don't do any of this if you are using stacki-docker
with the stacki-kubernetes pallet. Just follow those docs and you'll
be good. ***

This is the tl;dr. It's actually kinda long for a tl;dr but it's shorter than the full set of instructions in which I give you far more details than you want.

<h2>tl;dr</h2>

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

Change the default network if you have something else you require.

Swarm is default enabled. And again, don't run the pallet if you're using
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
The "mkfsoptions" is a requirement for the overlay fs no matter what partition you put it on.
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
http://frontend.IP:3000 for grafana

<h2>Detailed Explanation</h2>

The stacki-docker pallet deploys Docker Community edition 17.03.0, with a flag to start Docker Swarm Mode. Without swarm mode, Docker runs with TLS certs on every backend and is availble to accept Docker images. In swarm mode, a designated manager (designated by you along with secondary managers and worker, automatically register themselves to the cluster at boot time, with no intervention from you. 

A demo of NGINX runs by default in Swarm mode because I do a snotload of demos. 

If you don't want this, set that flag to "false." See below in spreadsheet section.

The OS is CentOS 7.3 with updates if you downloaded them. You want to. The pallet provides a 4.10 kernel from elrepo because we are using overlay fs for /var/lib/docker. Overlay is only in preview for CentOS/RHEL 7.2/3 so I've added a modern kernel here. I imagine this helps with cgroups too. (I tossed that out there like I understand those. I don't so don't ask me anything about it.)

<h3>Software</h3>
You can't make an omelet without killing some chickens so get some software.

Download isos:
/export should be the largest partition on your frontend. If it's not, you probably messed something up during the frontend install. Pick the largest partition then. 

```
# cd /export
```

Make a directory to store the isos and then cd to it:
```
# mkdir isos
# cd isos
```

Download some software:
```
# wget https://s3.amazonaws.com/stacki/public/os/centos/7/CentOS-7-x86_64-Everything-1611.iso
# wget https://s3.amazonaws.com/stacki/public/os/centos/7/CentOS-Updates-7.3-7.x.x86_64.disk1.iso
# wget https://s3.amazonaws.com/stacki/public/pallets/3.2/open-source/stacki-docker-17.03.0-3.2_phase2.x86_64.disk1.iso
```

These are the md5sums for those pallets:
```
[root@stackdock isos]# md5sum *.iso
15f5c94708d0a2ce5244c5237bb9fb97  CentOS-7-x86_64-Everything-1611.iso
8c9f2f2608069d0b4792183822e0c8a7  CentOS-Updates-7.3-7.x.x86_64.disk1.iso
d461efc5592c77d3aed0a1dad279c3f3  stacki-docker-17.03.0-3.2_phase2.x86_64.disk1.iso
a97b53017a97e072054d25d24017bd02  stacki-prometheus-1.0-7.x.x86_64.disk1.iso
```

If you want monitoring too, get the prometheus pallet:
```
# wget https://s3.amazonaws.com/stacki/public/pallets/3.2/open-source/stacki-prometheus-1.0-7.x.x86_64.disk1.iso
```

There will be documentation on the StackIQ github stacki-prometheus page soon, real soon.

<h3>Frontend Setup</h3>
The following steps are pretty standard for adding an application pallet. A pallet tends to have configuration and software that needs to run on the frontend before installing backend nodes. It's different than a cart in this respect which only has configuration for backend nodes. 

stacki-docker is a even a little trickier in that the order in which you do things matters to get the proper result. If you screw-up a step, though, you can always redo them though without having to start at the absolute beginning.


Add/enable/disable pallets:

```
# stack add pallet *.iso
# stack list pallet
```

Looks like this:
```
[root@stackdock isos]# ls
CentOS-7-x86_64-Everything-1611.iso      stacki-docker-17.03.0-3.2_phase2.x86_64.disk1.iso
CentOS-Updates-7.3-7.x.x86_64.disk1.iso  stacki-prometheus-1.0-7.x.x86_64.disk1.iso

[root@stackdock isos]# stack add pallet *.iso
Copying "CentOS" (7,x86_64) pallet ...
Copying CentOS-Updates to pallets ...2349528 blocks
Copying stacki-docker to pallets ...322405 blocks
Copying stacki-prometheus to pallets ...112373 blocks

[root@stackdock isos]# stack list pallet
NAME               VERSION RELEASE    ARCH   OS     BOXES
os:                7.2     7.x        x86_64 redhat default
stacki:            3.2     7.x        x86_64 redhat default
CentOS:            7       ---------- x86_64 redhat -------
CentOS-Updates:    7.3     7.x        x86_64 redhat -------
stacki-docker:     17.03.0 3.2_phase2 x86_64 redhat -------
stacki-prometheus: 1.0     7.x        x86_64 redhat -------
```

You should see the newly added CentOS, CentOS-Updates, stacki-docker, and stacki-prometheus if you're using it. They will have dashes in the "BOXES" column which means they aren't active. We mostly don't enable things by default. Unless I tell you I did, in which case you have to undo the enable. 

You can't have two OS pallets. The "os" pallet is a minimal CentOS 7.2 pallet that is designed for the absolute minimal install. We assume there'll be a need for other things, so we add the CentOS and CentOS-Updates pallets. Which means you no longer need the "os" pallet. Disable it. If you don't disable it, weird things happen. (Usually involving failed backend installs but sometimes involving frogs in party hats.) 

Disable the "os" pallet.

```
[root@stackdock ~]# stack disable pallet os
Cleaning repos: stacki-3.2
Cleaning up everything

[root@stackdock ~]# stack list pallet
NAME               VERSION RELEASE    ARCH   OS     BOXES
os:                7.2     7.x        x86_64 redhat -------
stacki:            3.2     7.x        x86_64 redhat default
CentOS:            7       ---------- x86_64 redhat -------
CentOS-Updates:    7.3     7.x        x86_64 redhat -------
stacki-docker:     17.03.0 3.2_phase2 x86_64 redhat -------
stacki-prometheus: 1.0     7.x        x86_64 redhat -------
```

Now we're going to enable the pallets we want to use. Once they are enabled, they are listed in the /etc/yum.repos.d/stacki.repo file and availble via yum to the frontend and all the backends.
```
[root@stackdock ~]#  stack enable pallet CentOS CentOS-Updates stacki-docker stacki-prometheus
Cleaning repos: CentOS-7 CentOS-Updates-7.3 stacki-3.2 stacki-docker-17.03.0 stacki-prometheus-1.0
Cleaning up everything

[root@stackdock ~]# stack list pallet
NAME               VERSION RELEASE    ARCH   OS     BOXES
os:                7.2     7.x        x86_64 redhat -------
stacki:            3.2     7.x        x86_64 redhat default
CentOS:            7       ---------- x86_64 redhat default
CentOS-Updates:    7.3     7.x        x86_64 redhat default
stacki-docker:     17.03.0 3.2_phase2 x86_64 redhat default
stacki-prometheus: 1.0     7.x        x86_64 redhat default
```

We are not quite done with frontend set-up yet. We need to pre-populate some attributes, key/value pairs, that have to be set before we can run the stacki-docker pallet to set up the configuration. 

<h3>Spreadsheets</h3>

Install the spreadsheets examples for docker. These will be in /export/stack/spreadsheets/examples. They're CSV files. They are easier to see and change if you open them in Google Docs or Excel. Then export back to CSV and load them.

```
[root@stackdock ~]# yum install stacki-docker-spreadsheets -y
Resolving Dependencies
--> Running transaction check
---> Package stacki-docker-spreadsheets.noarch 0:0-3.2_phase2 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=============================================================================================================================
 Package                                Arch               Version                   Repository                         Size
=============================================================================================================================
Installing:
 stacki-docker-spreadsheets             noarch             0-3.2_phase2              stacki-docker-17.03.0             2.8 k

Transaction Summary
=============================================================================================================================
Install  1 Package

Total download size: 2.8 k
Installed size: 1.0 k
Downloading packages:
stacki-docker-spreadsheets-0-3.2_phase2.noarch.rpm                                                    | 2.8 kB  00:00:00
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : stacki-docker-spreadsheets-0-3.2_phase2.noarch                                                            1/1
  Verifying  : stacki-docker-spreadsheets-0-3.2_phase2.noarch                                                            1/1

Installed:
  stacki-docker-spreadsheets.noarch 0:0-3.2_phase2

Complete!
```

The spreadsheet we are first concerned with contains only the global attributes needed to run the stacki-pallet. There are other ways to do this, but going step by step gives you a feel for what needs to be done in toto.

```
[root@stackdock ~]# cd /export/stack/spreadsheets/examples/

[root@stackdock examples]# cat global-docker-attrs-swarm.csv

target,docker.registry.external,docker.registry.local,docker.swarm,docker.swarm.demo,docker.swarm.manager,docker.swarm.manager_ip,docker.swarm.node,docker.swarm.overlay_network,docker.swarm.overlay_network_name,docker.swarm.secondary_manager,docker.experimental
global,True,False,True,True,False,10.1.255.254,True,172.16.10.0/24,testnet,False,True
```
Opening this in Google Docs looks like this:




Open your firewall.




<h3>Backend Setup</h3>

