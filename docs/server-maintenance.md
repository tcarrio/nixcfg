# Server maintenance

Hardware breaks. This is inevitable. I'm not running some hyper redundant boot scheme or dual PSU setup at all, but every once in awhile things are going to die.

## Hard drives

Spinning metal, much like the wheels on your car, are going to eventually need re-tightening, lubed bolts, etc. These disks that spin over 5000 times *per minute* certainly will fail. They do a great job to make them last but there are also ways to keep ahead of the failure as well.

**First rule**: Always use a RAID setup with *some level* of redundancy. RAID 1, 5, or 6 work for this.

To break each of these down:

- **RAID 1**: Mirrored disks. The disks contain identical data and if one dies, the other is still available. There is little impact to reads/writes but is largely the most wasteful option in other aspects. If you bought 10 drives each with 1TB of storage, you'll get 5TB of usable disk space.
- **RAID 5**: Block striping with a single parity block. Supposing you have 10 drives like before, for each block written across the first 9 disks, the 10th block will be a parity block. This is a calculated value against the data blocks in this stripe. Much like you can solve for a variable in an equation if all the other values are known (given `10 = 2 + 4 + x` you can solve `x`), the parity block allows you to determine what the block content should be if one of the disks fails. The meaning of *single* parity is that the limit of RAID 5's maximum concurrent disk failure is **one**. If another disk fails before recovery, you are SOL. You only "sacrifice" the storage of one disk though, so for 10 x 1TB disks in RAID 5 you will get 9TB usable space.
- **RAID 6**: Block string with two parity blocks. Everything nice about RAID 5, but two disks will be sacrificed. This provides more redundancy at the cost of more storage. In the same scenario as before, 10 x 1TB disks in RAID 6 will get you 8TB usable space.

### S.M.A.R.T.y pants

Any recent hard drive worth anything is going to have built in support for S.M.A.R.T. This is a device-level integration for detecting and reporting errors from the disk itself. If a hard drive has S.M.A.R.T. support, you can tell it to scan for errors intermittently and, with luck on your side, detect a failure *ahead of time*.

On Linux, a great tool for this is the `smartmontools` suite. The Arch Linux wiki has great information for ways to interact with the `smartctl` CLI to run and analyze hard drive disk tests.

Some useful commands:

- `smartctl --info $device`: Show info such as whether SMART is available and enabled
- `smartctl -t short $device`: Run a short test suite, usually takes a few minutes.
- `smartctl -t long $device`: Run a long test suite, usually takes hours.
- `smartctl -H $device`: Show the results of the device's tests.