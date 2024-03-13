{ ... }: let
  fullBlocklistProjectTrackerList = {
    Abuse = ["https://blocklistproject.github.io/Lists/abuse.txt"];
    Ads = ["https://blocklistproject.github.io/Lists/ads.txt"];
    Crypto = ["https://blocklistproject.github.io/Lists/crypto.txt"];
    Drugs = ["https://blocklistproject.github.io/Lists/drugs.txt"];
    Everything = ["https://blocklistproject.github.io/Lists/everything.txt"];
    Facebook = ["https://blocklistproject.github.io/Lists/facebook.txt"];
    Fraud = ["https://blocklistproject.github.io/Lists/fraud.txt"];
    Gambling = ["https://blocklistproject.github.io/Lists/gambling.txt"];
    Malware = ["https://blocklistproject.github.io/Lists/malware.txt"];
    Phishing = ["https://blocklistproject.github.io/Lists/phishing.txt"];
    Piracy = ["https://blocklistproject.github.io/Lists/piracy.txt"];
    Porn = ["https://blocklistproject.github.io/Lists/porn.txt"];
    Ransomware = ["https://blocklistproject.github.io/Lists/ransomware.txt"];
    Redirect = ["https://blocklistproject.github.io/Lists/redirect.txt"];
    Scam = ["https://blocklistproject.github.io/Lists/scam.txt"];
    TikTok = ["https://blocklistproject.github.io/Lists/tiktok.txt"];
    Torrent = ["https://blocklistproject.github.io/Lists/torrent.txt"];
    Tracking = ["https://blocklistproject.github.io/Lists/tracking.txt"];
  };
in {
  services.blocky = {
    enable = true;
    settings = rec {
      port = 53; # Standard DNS port
      upstream.default = [
        # Using Cloudflare's DNS over HTTPS server for resolving queries.
        "https://one.one.one.one/dns-query"
      ];
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };
      # Enable Blocking of certain domains.
      blocking = {
        blackLists = {
          (inherit fullBlcklistProjectTrackerList) Abuse Ads Crypto Drugs Fraud Gambling Malware Phishing Ransomware Scam Torrent Tracking;
        };
      };
      # Configure what block categories are used
      clientGroupsBlock = {
        default = builtins.attrNames blocking.blackLists;
      };
    };
  };
}
