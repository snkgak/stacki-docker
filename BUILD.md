This is how you build the stacki-docker pallet.
You should have the 7.2 or 7.3 CentOS added
as a pallet on the frontend.

If you want the latest and greatest stable docker
do:

# make refresh

then, if this is the first time:

# make bootstrap

Now make the pallet:

# make

To add the pallet:

# stack add pallet build-stacki-docker-master/stacki-docker-1.13.0-7.x.x86_64.disk1.iso

Enable it:

# stack enable pallet stacki-docker

Then go get kubernetes.
