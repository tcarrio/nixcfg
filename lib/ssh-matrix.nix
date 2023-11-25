_:
let
  parseFriendlyKey = builtins.replaceStrings [ "\n" ] [ "" ];
in
{
  # user@host matrix
  systems = {
    sktc0 = {
      tcarrio = parseFriendlyKey ''
        ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAy
        NTYAAABBBAl788s2f8cUb8v3pyqX1sv4jRpvBuWeC0pfp+p0Gq1eLKBv9GxENTl1
        46PoqAMkXQB2CJE8KX7vbjZrrirJBBc= GitHub@secretive.alum.local
      '';
    };
    glass = {
      host = parseFriendlyKey ''
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDC1bp1dPv/g2DkghZprPoxqtxcq
        SZx5D0AG0rkR7BIDhYfrHGSLsre/RoL38epPpaitKWXr6C/Cbqgby9K/zLgBG+BGH
        KVmYGrvmQU+NlUjlhKrotaVFhJ5Q8RYDnX+8dZcjeKs5sCRGnU76AfoXm4RCggesJ
        B4QThragtgEOrmaEUzTZJ4uRKYACNYNiYtggYMIk6X9E0fK0Jxh+YW9zvIwvzWc+S
        rjlCC2YqHSN+OKvco/6yLn+deT0SqIl027f181DtsgogsVAGXVzFVJ/1REXxuonEh
        jjoqn7n7A9Yu3mIc8jLa8XZaW3bIjb0R15PG35Ou9pCwfhFp1wOePDUojrv+JHaQB
        9pfiRK7ij6A6lGArBiKMIpL76RSRXNuATkTb9fXm24we1kt1uQ87dWze/mu6YakAl
        G9zESCYrp6l5YF2hCo7Nd9M9UFG/fjSQWvyOpUshgocqOUsttpluBs+R0h8T9+pvv
        2czORlO7WxeQrF5rEFNYwh/l5KwxA9VppTsZu29xXPYGb3pE+FeRFAMqy+l0lyJ9P
        zthIUlJgLRxH4xg23X8BpOXSA40O2HnIISbGgzDEgqzYZ79y+TrYeEICD+0NWIuos
        D1iJ7m8RkuC6NsU4bo9nHBBtIr69Ia6yt4IHz8b5jgdXw2rzfqYYIRkIicgDqpu0v
        SBkL7aQ== root@glass
      '';
      tcarrio = parseFriendlyKey ''
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDe7xvr45OB0rHkLy9EWSxGGe/Op
        mMqawr90+d/RXTP2F9H/X7DDByLuH1VMNtjYAltnRO4zQW6vod90EptfuiTOl6B1l
        ipg2abkRg8yFe+BWSzgNdtzmaKp0UEA6+EbeQft/zGEaPcibcJT8OFEeGdYeMthq5
        bXiFowgBgdIaMxNo5wn7SButgvT6Jo9VXyWUbMG/HkIKpNzNP1bfMhYcrGGWVfiu3
        Lyvulj2lJ4OkbEXMQN+sPE+Ti5rUX07zc0sqAvohRxTwAeSJM7RndD4+rEb/tj8bp
        HYbvcZwmvmVculh/5+vDnWRXJCjbuj6gMnvn2Njbz7Mu6xRZx+ev4SdXpO5vdvd2B
        BV08fvrWx3iMAqGNppqS0h4UadtApWkx1TjMMuvyk+SZmAtv8OQ662SauS3pIUpr+
        o8D7BjS8my1mQP5MMW7M3rvpBJ5TlKf2RecDR43R1MZdKzgtKmTLtlarna30Xt4ph
        DXhpyW7C5L9DruZ9MV1Gc4820juIplmN2/WGcwvLGxu+YMiN7jm26T/2bogr039Bp
        cb3aPLTTm1dkC4qowcFQ7Eww3QH5ECRg8e8b/BaQgA0CUXOZxDSIH3X3c0LdEUCuX
        VrCc9bHK8U8XFijbMkosIQabudqPiXBXDsrKDSu0qI//T315EfNeXGCocmM5Ujb2P
        7a2zZFQ== tom@carrio.dev
      '';
    };
    kuroi = {
      host = parseFriendlyKey ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAT4Z64F9AhDZ60xzv9TOAf/+PJQK
        VQ+hf8ar3nEzpmm root@kuroinixu
      '';
    };
  };
}
