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
