{ config, desktop, lib, pkgs, ... }: {
  imports = [ ];

  environment.packages = [
    pkgs.yadm # Terminal dot file manager
  ];

  users.users.tcarrio = {
    description = "Tom Carrio";
    extraGroups = [
      "audio"
      "input"
      "networkmanager"
      "users"
      "video"
      "wheel"
    ];
    # mkpasswd -m sha-512
    hashedPassword = "$6$uLtXsdZpgBd/iVao$L3Lk9vmQMOfZrARIyl6Sq6ZbU91d53dWQteZADxkgLJ8FZUet.L4E73LnmVccJUGdAUcMQ1cuISS9j0XygM2Q1";
    homeMode = "0755";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      # Add any authorized keys for SSH access here
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDe7xvr45OB0rHkLy9EWSxGGe/OpmMqawr90+d/RXTP2F9H/X7DDByLuH1VMNtjYAltnRO4zQW6vod90EptfuiTOl6B1lipg2abkRg8yFe+BWSzgNdtzmaKp0UEA6+EbeQft/zGEaPcibcJT8OFEeGdYeMthq5bXiFowgBgdIaMxNo5wn7SButgvT6Jo9VXyWUbMG/HkIKpNzNP1bfMhYcrGGWVfiu3Lyvulj2lJ4OkbEXMQN+sPE+Ti5rUX07zc0sqAvohRxTwAeSJM7RndD4+rEb/tj8bpHYbvcZwmvmVculh/5+vDnWRXJCjbuj6gMnvn2Njbz7Mu6xRZx+ev4SdXpO5vdvd2BBV08fvrWx3iMAqGNppqS0h4UadtApWkx1TjMMuvyk+SZmAtv8OQ662SauS3pIUpr+o8D7BjS8my1mQP5MMW7M3rvpBJ5TlKf2RecDR43R1MZdKzgtKmTLtlarna30Xt4phDXhpyW7C5L9DruZ9MV1Gc4820juIplmN2/WGcwvLGxu+YMiN7jm26T/2bogr039Bpcb3aPLTTm1dkC4qowcFQ7Eww3QH5ECRg8e8b/BaQgA0CUXOZxDSIH3X3c0LdEUCuXVrCc9bHK8U8XFijbMkosIQabudqPiXBXDsrKDSu0qI//T315EfNeXGCocmM5Ujb2P7a2zZFQ== tom@carrio.dev"
    ];
    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };
}
