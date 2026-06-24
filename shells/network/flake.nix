{
  description = "Nix shell for network tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        isDarwin = pkgs.system == "x86_64-darwin" || pkgs.system == "aarch64-darwin";
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bind # dns-sd for mDNS/Bonjour
            curlie # Terminal HTTP client
            dnsutils # dig, nslookup
            gnugrep # Text processing
            httpie # Terminal HTTP client
            iperf3 # Terminal network benchmarking
            mtr # Modern Unix `traceroute`
            net-tools # arp, ifconfig, netstat
            nmap # Network scanning
            tcpdump # Packet capture
          ] ++ lib.optionals (isDarwin) [
            netdiscover # Modern Unix `arp`
          ] ++ lib.optionals (!isDarwin) [
            bmon # Modern Unix `iftop`
            dogdns # Modern Unix `dig`
            nethogs # Modern Unix `iftop`
            ookla-speedtest # Terminal speedtest
            wavemon # Terminal WiFi monitor
          ];
        };
      }
    );
}
