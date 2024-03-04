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

# Disk partition information

```
NAME    MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
sda       8:0    0 111.8G  0 disk  
└─md126   9:126  0 670.4G  0 raid6 /storage/ssds
sdb       8:16   0 111.8G  0 disk  
└─md126   9:126  0 670.4G  0 raid6 /storage/ssds
sdc       8:32   0 111.8G  0 disk  
└─md126   9:126  0 670.4G  0 raid6 /storage/ssds
sdd       8:48   0 111.8G  0 disk  
└─md126   9:126  0 670.4G  0 raid6 /storage/ssds
sde       8:64   0 111.8G  0 disk  
└─md126   9:126  0 670.4G  0 raid6 /storage/ssds
sdf       8:80   0 111.8G  0 disk  
└─md126   9:126  0 670.4G  0 raid6 /storage/ssds
sdg       8:96   0 111.8G  0 disk  
└─md126   9:126  0 670.4G  0 raid6 /storage/ssds
sdh       8:112  0 111.8G  0 disk  
└─md126   9:126  0 670.4G  0 raid6 /storage/ssds
sdi       8:128  0 298.1G  0 disk  
sdj       8:144  0 238.5G  0 disk  
├─sdj1    8:145  0 222.5G  0 part  /
├─sdj2    8:146  0     1K  0 part  
└─sdj5    8:149  0    16G  0 part  [SWAP]
sdk       8:160  0 931.5G  0 disk  
└─md127   9:127  0   2.7T  0 raid5 /srv/media
                                   /storage/hdds
sdl       8:176  0 931.5G  0 disk  
└─md127   9:127  0   2.7T  0 raid5 /srv/media
                                   /storage/hdds
sdm       8:192  0 931.5G  0 disk  
└─md127   9:127  0   2.7T  0 raid5 /srv/media
                                   /storage/hdds
sdn       8:208  0 931.5G  0 disk  
└─md127   9:127  0   2.7T  0 raid5 /srv/media
                                   /storage/hdds
```

```
Disk /dev/sdi: 298.09 GiB, 320072933376 bytes, 625142448 sectors
Disk model: WDC WD3200AAKS-0
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdj: 238.47 GiB, 256060514304 bytes, 500118192 sectors
Disk model: Corsair CMFSSD-2
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x54cdf023

Device     Boot     Start       End   Sectors   Size Id Type
/dev/sdj1  *         2048 466618367 466616320 222.5G 83 Linux
/dev/sdj2       466620414 500117503  33497090    16G  5 Extended
/dev/sdj5       466620416 500117503  33497088    16G 82 Linux swap / Solaris
The primary GPT table is corrupt, but the backup appears OK, so that will be used.


Disk /dev/sdk: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: WDC WD10EFRX-68F
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: E49C7BCD-9BB7-4D33-9DE8-EB7CFEF781AC

Device     Start        End    Sectors   Size Type
/dev/sdk1   2048 1953525134 1953523087 931.5G Linux RAID
The primary GPT table is corrupt, but the backup appears OK, so that will be used.


Disk /dev/sdm: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: WDC WD10EFRX-68P
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: C7686AE5-315E-4557-A632-8F5A7F817A87

Device     Start        End    Sectors   Size Type
/dev/sdm1   2048 1953525134 1953523087 931.5G Linux RAID
The primary GPT table is corrupt, but the backup appears OK, so that will be used.


Disk /dev/sdn: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: WDC WD10EFRX-68P
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 27EC78A2-79E0-4FCC-8FD5-C14E6455196D

Device     Start        End    Sectors   Size Type
/dev/sdn1   2048 1953525134 1953523087 931.5G Linux RAID
The primary GPT table is corrupt, but the backup appears OK, so that will be used.


Disk /dev/sdb: 111.8 GiB, 120040980480 bytes, 234455040 sectors
Disk model: WDC WDS120G2G0A-
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 15613000-ADFC-482C-9B42-F370417CC09E

Device     Start       End   Sectors   Size Type
/dev/sdb1   2048 234455006 234452959 111.8G Linux RAID
The primary GPT table is corrupt, but the backup appears OK, so that will be used.


Disk /dev/sda: 111.8 GiB, 120040980480 bytes, 234455040 sectors
Disk model: WDC WDS120G2G0A-
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 61C99D01-5599-4D3B-8B42-3943ECFA28F1

Device     Start       End   Sectors   Size Type
/dev/sda1   2048 234455006 234452959 111.8G Linux RAID
The primary GPT table is corrupt, but the backup appears OK, so that will be used.


Disk /dev/sdc: 111.8 GiB, 120040980480 bytes, 234455040 sectors
Disk model: WDC WDS120G2G0A-
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 1BFDEAD1-0999-4AC6-A6C7-2A4503F3A1C6

Device     Start       End   Sectors   Size Type
/dev/sdc1   2048 234455006 234452959 111.8G Linux RAID
The primary GPT table is corrupt, but the backup appears OK, so that will be used.


Disk /dev/sdh: 111.8 GiB, 120040980480 bytes, 234455040 sectors
Disk model: WDC WDS120G2G0A-
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: EB8FB32B-7BD6-45E8-A7D2-D03A1854B313

Device     Start       End   Sectors   Size Type
/dev/sdh1   2048 234455006 234452959 111.8G Linux RAID
The primary GPT table is corrupt, but the backup appears OK, so that will be used.


Disk /dev/sde: 111.8 GiB, 120040980480 bytes, 234455040 sectors
Disk model: WDC WDS120G2G0A-
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 5366E018-52DA-45A8-A9A5-EA6872E1590C

Device     Start       End   Sectors   Size Type
/dev/sde1   2048 234455006 234452959 111.8G Linux RAID
The primary GPT table is corrupt, but the backup appears OK, so that will be used.


Disk /dev/sdl: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: WDC WD10EFRX-68F
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 97E93A5E-6D2F-4BA0-8FF9-B0092ED419AC

Device     Start        End    Sectors   Size Type
/dev/sdl1   2048 1953525134 1953523087 931.5G Linux RAID


Disk /dev/sdf: 111.8 GiB, 120040980480 bytes, 234455040 sectors
Disk model: WDC WDS120G2G0A-
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00000000

Device     Boot Start       End   Sectors   Size Id Type
/dev/sdf1           1 234455039 234455039 111.8G ee GPT


Disk /dev/sdd: 111.8 GiB, 120040980480 bytes, 234455040 sectors
Disk model: WDC WDS120G2G0A-
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00000000

Device     Boot Start       End   Sectors   Size Id Type
/dev/sdd1           1 234455039 234455039 111.8G ee GPT
The primary GPT table is corrupt, but the backup appears OK, so that will be used.


Disk /dev/sdg: 111.8 GiB, 120040980480 bytes, 234455040 sectors
Disk model: WDC WDS120G2G0A-
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: D7BC14E3-D8F0-4F91-B8B0-DA24C4C0A3B6

Device     Start       End   Sectors   Size Type
/dev/sdg1   2048 234455006 234452959 111.8G Linux RAID


Disk /dev/md127: 2.73 TiB, 3000208195584 bytes, 5859781632 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 262144 bytes / 786432 bytes


Disk /dev/md126: 670.4 GiB, 719836938240 bytes, 1405931520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 262144 bytes / 1572864 bytes
```