let
  sshMatrix = import ../lib/ssh-matrix.nix { };
  inherit (sshMatrix) groups systems;
  inherit (systems) glass;

  pqKey = ''
    age1pq136et39g9t6g628jwq6kzx63ewv6t567q5clv3psyy3t0r7a9wuwzqndy2cz4vuuufn9cfv3a4ljp3uf6zs0qsxygyfgaremvtdyqxzgzds0nydfrs5ckgdax2l3pc8qc35hpzgygyxslx264zzyp2eqmfuu0tp9ymyqw0vs90mxgn8rrgcqh0ta35ffzra5swd7frzcuret44x3a65nm6fmm29zuml7nv9zvkwef4s7fxqt3nvgz5mcvkpnt3wg6s9rqc2xwc656z7yuv4utrpcjjccz9wemvzcszz83xtu2t80hzd0zpwg6ff5vdxk83d89tjjjkcvjlwtwr22tv59czq7j9s29yufuuarkwv9mgm3y2xvdva2exwtulc5up02tzlq2gmutfsswptxshqrq623frpkcn6rcpzyxyj0c4q3ftmpfspat3ld4cw9m6y0g3vnf7acjl2xktsqsjdgnvvlt7a2rxljksz3he8u5j6dsezajupaz689vh3qrq26zhsqqvf490fujvt9ue9kkdkk64qmr8gf3tkvyy698pug8qqdw5e72agr354pfcfqejat9nnrrj3qh32r92yrl3lq5qdzu8pq8cq4shxqtypge689rwwdxhfpmqt7xgshn9pte3jmsrne8rmqf4gvuhpg5ker0svegh9ev30u8jtm8wfwn53ky8yrfes3splklfqnu7v36fgq9neyma55c5l9fnvxwn0quqd49tvax9jakegvapgyr228sr6jl2ur5zlttzyc3fjd53da36zdkfu4hgf4rew9yskpvq6h2ra62z7x25z0996ruxwak8fdpt5d2r2a4rdegc24qskpfvwen0sx8vrs9g8cx4z4dktz6r2kr63trt7ztqwfzevthejsx24eq7j5gv8ccdulre70dk2enz209rxe6dvd8duwgtvr8km67ppvuwy7zaqnqdfkhkttyxh79rgvgva3ushek2339qp74gvg0yz3qzkjs0ntkla5pc63a0r5hcg3lrz5mpq9sedyvgg3j908r6jc6l7vr4h2jlz2u46mts3qyv64xnnqndl5e5vkztzyyv8pmupxvacv8sesrhv9nyd85nf0wm9zdqvcwj47840hznmsmchnh0p9vg3p3z9p3paazkgu9ppspap46s7qjje53wfk8w2uqyk2hqgr9wuqumyc5aq4chre5900ymwsaqpg9mhamm9ws2uemexxc40zg4ekz9mcp3gged7rt88jvkj0ddge9zqg4dsg4w82qnj9hpdy0j5kflgzt4jx52t9rw3n54zselyrp6jk8rqznprwn255nnv4x78qg2cpeasj3p4y70wvvd98mh6fc4cs8nkzgwn5qd2wkktzw5yeacgwfpv23v5am5zzals2rgqqnhdtpf4ehzzw58jxm9rpy9qfx6x6zaz5x54200qj88p46cvfr4lt5ry2kt9j7yg3njuk6z59txwv860yfzzxczwd0g6kht2e20t2x3md8j4mazxr967ul4af7z63nq4qjvdsmyp5g2pdgw2689pnj9kcfhgpl52s4rtreq2pde9ugnrmfjz8s5w9pcsvqeusrnuj939k5hmtw48f3k5c0pwchaxgu823kzx9mrjuvgue799metxvzwsaykgpug99rfgav2zt545ar6lf62254chaxm2qfa7zhq93hfseepjkuxmqds79a03qhjktvvw0ztujxka43ganmwgsw7hq26mxey9am2v4zj4yh55zqeseq5yx68z2qdjzjka0c52d65hmrf58x2j6dc4tur2kwgckvewn2kne8rtnwggv6ry2tjt8zrh4ju73u4tetp265vkdv7wkqj2smuufyrag0c0czav2tpgs8h24rpu0lyzp4zzfww2q96tpdpk7jmtnaducqmy5m3nsgkq49pqavmwyj
  '';

  mapSetValues = f: set:
    map f (
      map (key: set.${key}) (builtins.attrNames set)
    );

  allSystemHostKeys = builtins.filter
    (host: host != null)
    (mapSetValues
      (system: if (system ? host) then system.host else null)
      systems
    );

  autoMeshSystems = allSystemHostKeys;

  base = groups.privileged_users ++ [pqKey];
in
{
  "users/tcarrio/ssh.age".publicKeys = base ++ [ glass.tcarrio glass.host ];
  "services/netbird/token.age".publicKeys = base ++ autoMeshSystems;
  "services/tailscale/token.age".publicKeys = base ++ autoMeshSystems;
  # "services/jira-cli/token.age".publicKeys = macos;
  "services/acme/cloudflare.age".publicKeys = base;
  "services/hoarder/env.age".publicKeys = base ++ [ systems.obsidian.host ];

  "network-shares/ds418/smb.conf.age".publicKeys = base;

  # primarily maintained via agenix for convenience of scripting automations
  "hosts/nuc0/ssh_host_ed25519_key.age".publicKeys = base;
  "hosts/nuc1/ssh_host_ed25519_key.age".publicKeys = base;
  "hosts/nuc2/ssh_host_ed25519_key.age".publicKeys = base;
  "hosts/nuc3/ssh_host_ed25519_key.age".publicKeys = base;
  "hosts/nuc4/ssh_host_ed25519_key.age".publicKeys = base;
  "hosts/nuc5/ssh_host_ed25519_key.age".publicKeys = base;
  "hosts/nuc6/ssh_host_ed25519_key.age".publicKeys = base;
  "hosts/nuc7/ssh_host_ed25519_key.age".publicKeys = base;
  "hosts/nuc8/ssh_host_ed25519_key.age".publicKeys = base;
  "hosts/nuc9/ssh_host_ed25519_key.age".publicKeys = base;

  # spotify + mopidy
  "services/spotify/client.age".publicKeys = groups.users;
}
