# blck0

A network storage server, primarily. Consists of a 3TB HDD RAID array and a 660GB SSD RAID array.

# SSD RAID Array

```
          Magic : a92b4efc
        Version : 1.2
    Feature Map : 0x1
     Array UUID : 39b41600:30790cc1:57604ab6:d7019eb9
           Name : core:solid_raid
  Creation Time : Sun Sep 13 03:14:54 2020
     Raid Level : raid6
   Raid Devices : 8

 Avail Dev Size : 234321920 sectors (111.73 GiB 119.97 GB)
     Array Size : 702965760 KiB (670.40 GiB 719.84 GB)
    Data Offset : 133120 sectors
   Super Offset : 8 sectors
   Unused Space : before=133040 sectors, after=0 sectors
          State : clean
    Device UUID : a69f0a6f:1026dfcd:e4fa6db9:fcd4ad96

Internal Bitmap : 8 sectors from superblock
    Update Time : Mon Mar  4 00:58:52 2024
  Bad Block Log : 512 entries available at offset 16 sectors
       Checksum : 8d2e4a2e - correct
         Events : 207

         Layout : left-symmetric
     Chunk Size : 256K

   Device Role : Active device 0
   Array State : AAAAAAAA ('A' == active, '.' == missing, 'R' == replacing)
```

# HDD RAID Array

```
          Magic : a92b4efc
        Version : 1.2
    Feature Map : 0x1
     Array UUID : 88e0c57f:7c1dc29c:3541784d:cfc9d098
           Name : core:hard_raid
  Creation Time : Sun Sep 13 03:15:43 2020
     Raid Level : raid5
   Raid Devices : 4

 Avail Dev Size : 1953260976 sectors (931.39 GiB 1000.07 GB)
     Array Size : 2929890816 KiB (2.73 TiB 3.00 TB)
  Used Dev Size : 1953260544 sectors (931.39 GiB 1000.07 GB)
    Data Offset : 264192 sectors
   Super Offset : 8 sectors
   Unused Space : before=264112 sectors, after=432 sectors
          State : clean
    Device UUID : 60f3af70:37a5cdc1:6ac41214:4dfc1657

Internal Bitmap : 8 sectors from superblock
    Update Time : Mon Mar  4 00:58:53 2024
  Bad Block Log : 512 entries available at offset 16 sectors
       Checksum : 31115d32 - correct
         Events : 4555

         Layout : left-symmetric
     Chunk Size : 256K

   Device Role : Active device 3
   Array State : AAAA ('A' == active, '.' == missing, 'R' == replacing)
```

# Services

```
  UNIT                      LOAD   ACTIVE SUB     DESCRIPTION                                   
  avahi-daemon.service      loaded active running Avahi mDNS/DNS-SD Stack
  cron.service              loaded active running Regular background program processing daemon
  cups-browsed.service      loaded active running Make remote CUPS printers available locally
  cups.service              loaded active running CUPS Scheduler
  dbus.service              loaded active running D-Bus System Message Bus
  exim4.service             loaded active running LSB: exim Mail Transport Agent
  getty@tty1.service        loaded active running Getty on tty1
  lightdm.service           loaded active running Light Display Manager
  mdmonitor.service         loaded active running MD array monitor
  ModemManager.service      loaded active running Modem Manager
  nfs-blkmap.service        loaded active running pNFS block layout mapping daemon
  nfs-idmapd.service        loaded active running NFSv4 ID-name mapping service
  nfs-mountd.service        loaded active running NFS Mount Daemon
  nfsdcld.service           loaded active running NFSv4 Client Tracking Daemon
  nmbd.service              loaded active running Samba NMB Daemon
  polkit.service            loaded active running Authorization Manager
  rpc-statd.service         loaded active running NFS status monitor for NFSv2/3 locking.
  rpcbind.service           loaded active running RPC bind portmap service
  rsyslog.service           loaded active running System Logging Service
  rtkit-daemon.service      loaded active running RealtimeKit Scheduling Policy Service
  smbd.service              loaded active running Samba SMB Daemon
  ssh.service               loaded active running OpenBSD Secure Shell server
  systemd-journald.service  loaded active running Journal Service
  systemd-logind.service    loaded active running User Login Management
  systemd-timesyncd.service loaded active running Network Time Synchronization
  systemd-udevd.service     loaded active running Rule-based Manager for Device Events and Files
  tailscaled.service        loaded active running Tailscale node agent
  udisks2.service           loaded active running Disk Manager
  user@1001.service         loaded active running User Manager for UID 1001
  user@113.service          loaded active running User Manager for UID 113
  wpa_supplicant.service    loaded active running WPA supplicant
```