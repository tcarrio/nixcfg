# shiroi

A media and network storage server.

This houses multiple RAID arrays:

- A 4-disk RAID-5 of WD Red HDDs
- An 8-disk RAID-6 of WD SSDs

The HDDs are connected to mainboard SATA sockets whereas the SSDs are connected via SAS-SATA cables with 4xSATA to each SAS socket in a MegaRAID SAS PCI card.

## Disk information

```text
# Root disk
/dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002 -> /dev/sdb

# WD Red HDDs
/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J7TLCSNX -> /dev/sdc
/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XV4KDD -> /dev/sdd
/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XR859D -> /dev/sde
/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J2TJHS9P -> /dev/sdf

# WD SSDs
/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R479906 -> /dev/sdh
/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R479914 -> /dev/sdi
/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R440706 -> /dev/sdj
/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R471806 -> /dev/sdk
/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R463915 -> /dev/sdl
/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R458505 -> /dev/sdm
/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R463905 -> /dev/sdn
/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R451904 -> /dev/sdo

# Miscellaneous, unused
/dev/disk/by-id/ata-WDC_WD3200AAKS-00L9A0_WD-WCAV21751761 -> /dev/sda
```