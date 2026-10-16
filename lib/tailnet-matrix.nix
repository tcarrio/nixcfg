# Tailnet IP matrix for nixcfg-managed hosts only (plus nas-ds418-00,
# which is not flake-managed). No TVs, phones, or unmanaged devices.
#
# Regenerate candidates from:
# tailscale status --json | jq -r '[.Peer[], .Self][] | select(.TailscaleIPs[0] != null) | "\(.HostName) \(.TailscaleIPs[0])"'
# then keep only managed hostnames. Devices missing from the tailnet
# (offline-expired) drop out until they rejoin.
#
# Known renames: astral now reports as sktc2.
# DO NOT EDIT THE FOLLOWING MANUALLY
{
  "astral" = "100.89.92.124";
  "gokin" = "100.127.161.36";
  "nas-ds418-00" = "100.85.25.62";
  "obsidian" = "100.126.103.29";
  "orca" = "100.67.237.124";
  "phoenix" = "100.97.26.114";
  "sktc2" = "100.89.92.124";
  "void" = "100.93.120.101";
}
