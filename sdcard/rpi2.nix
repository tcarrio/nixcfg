{ ... }: {
  nixpkgs.crossSystem.system = "armv7l-linux";

  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
  ];

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDe7xvr45OB0rHkLy9EWSxGGe/OpmMqawr90+d/RXTP2F9H/X7DDByLuH1VMNtjYAltnRO4zQW6vod90EptfuiTOl6B1lipg2abkRg8yFe+BWSzgNdtzmaKp0UEA6+EbeQft/zGEaPcibcJT8OFEeGdYeMthq5bXiFowgBgdIaMxNo5wn7SButgvT6Jo9VXyWUbMG/HkIKpNzNP1bfMhYcrGGWVfiu3Lyvulj2lJ4OkbEXMQN+sPE+Ti5rUX07zc0sqAvohRxTwAeSJM7RndD4+rEb/tj8bpHYbvcZwmvmVculh/5+vDnWRXJCjbuj6gMnvn2Njbz7Mu6xRZx+ev4SdXpO5vdvd2BBV08fvrWx3iMAqGNppqS0h4UadtApWkx1TjMMuvyk+SZmAtv8OQ662SauS3pIUpr+o8D7BjS8my1mQP5MMW7M3rvpBJ5TlKf2RecDR43R1MZdKzgtKmTLtlarna30Xt4phDXhpyW7C5L9DruZ9MV1Gc4820juIplmN2/WGcwvLGxu+YMiN7jm26T/2bogr039Bpcb3aPLTTm1dkC4qowcFQ7Eww3QH5ECRg8e8b/BaQgA0CUXOZxDSIH3X3c0LdEUCuXVrCc9bHK8U8XFijbMkosIQabudqPiXBXDsrKDSu0qI//T315EfNeXGCocmM5Ujb2P7a2zZFQ== tom@carrio.dev"
    ];
  }
}