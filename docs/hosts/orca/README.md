# orca

This host is a FreeBSD system managing a ZFS RAIDZ pool, Plex Media Server, Tailscale, and more to be determined.

## why FreeBSD?

The use of FreeBSD was done primarily as an experiment while running into issues with the server on NixOS. I like a lot of the design decisions from what I have read, the support for ZFS across the system is stellar, and the primary system configuration is extremely straightforward to read (See [rc.conf](./rc.conf)).

## what if you don't like it?

ZFS is supported on both FreeBSD and Linux now. There are plenty of success stories of users migrating across platforms, so long as you validate the versions used you can export and import the ZFS pools pretty easily. The general approach would be:

1. Export on the current host system. This cleanly disconnects the ZFS pool so metadata is safe and correct.
2. Transfer all disks in the pool if necessary. The disks contain the ZFS metadata on them.
3. Import on the new host system. The `zpool import` command will search the disks for ZFS metadata.

> **⚠️ It will be important to ensure compatibility in feature flags and ZFS versions across systems**.

## what if you want to expand your RAIDZ storage?

ZFS added support in the last few years for RAID-Z Expansion. This feature allows you to add an addition disk to your virtual device with a *reflow* strategy for the parity groups to be reapplied across all devices, including the new disk.

For me, I have a ZFS pool called `zdata` with a VDEV called `raidz1-0`. Suppose I have a new drive in `/dev/ada0`, I would run:

```
zpool attach zdata raidz1-0 /dev/ada0
```

### does FreeBSD ZFS support this?

**NO!** Out of the box, FreeBSD comes with `zfs-2.2.6-FreeBSD_g33174af15`. However, the first version of ZFS, specifically OpenZFS, to support VDEV expansion was `2.3.0`. So you cannot do this with the ZFS included with FreeBSD. Instead, you will need to migrate to OpenZFS first, upgrade the zpool, then you will be able to use features like `raidz_expansion`.

First, install OpenZFS

```sh
pkg update
pkg install openzfs
```

Next, disable the FreeBSD ZFS and enable OpenZFS in both the `/boot/loader.conf` and `/etc/rc.conf`.

```sh
# in /boot/loader.conf
zfs_load="NO"
openzfs_load="YES"

# in /etc/rc.conf
zfs_enable="NO"
openzfs_enable="YES"
```

Reboot your system.

```sh
reboot
```

> ⚠️ Important note here! **You will likely still be executing FreeBSD ZFS commands due to the `PATH` configuration**.
> 
> The OpenZFS commands are located under `/usr/local/sbin/` where the FreeBSD ZFS commands are under `/sbin/`. The latter comes first in the `PATH`.
>
> Optionally, you could alias the commands `zfs` and `zpool` to their OpenZFS paths in your shell. See your `$SHELL` documentation for reference.

You may not be able to see your zpool after your reboot.
You can run `zpool list` to list the zpools, and if it's not shown, run `zpool import` which will inspect and output information about available zpools.
If you find your zpool (we'll call it `$zpool`), you can run `zpool import $zpool` to add it.

Now, you will have an outdated zpool. You can upgrade this with one command: `zpool upgrade $zpool`.

You should see a number of ZFS features enabled for this drive upon success, e.g.:

```
Enabled the following features on 'zdata':
  redaction_list_spill
  raidz_expansion
  fast_dedup
  longname
  large_microzap
```

Per the note about `raidz_expansion`, your drive now supports the feature flag to expand your RAID-Z VDEVs!

You're not done yet though! This means you have support for the *feature flag only*. This does not mean you have *enabled* said feature flag.

You can check whether it's enabled (which it shouldn't be):

```sh
zpool get feature@raidz_expansion $zpool
```

And to enable it (if disabled):

```sh
zpool set feature@raidz_expansion=enabled $zpool
```

> ⚠️ Lastly, make sure your disk is NOT active or you will NOT be able to take any actions. This means unmounted or killing active processes working with the disk.
