# auto-generated from:
# tailscale status --json | jq '
#   [.Peer[], .Self] |
#   map({(.HostName): (.TailscaleIPs | map(select(test("^100\\\\."))) | first)}) |
#   add
# '
# DO NOT EDIT THE FOLLOWING MANUALLY
{
  "alum" = "100.122.112.4";
  "chasm" = "100.124.8.114";
  "DESKTOP-PM2L758" = "100.119.246.9";
  "gokin" = "100.127.161.36";
  "localhost" = "100.103.54.123";
  "motorola razr plus 2024" = "100.127.130.27";
  "nas-ds418-00" = "100.85.25.62";
  "obsidian" = "100.126.103.29";
  "orca" = "100.71.92.47";
  "sktc2" = "100.89.92.124";
  "void" = "100.93.120.101";
  "vpn-arn" = "100.111.125.110";
}
