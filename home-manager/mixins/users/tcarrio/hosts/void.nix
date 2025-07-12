_:
{
  imports = [
    ../../../console/ai/claude.nix
  ];

  ominix.enable = true;
  ominix.identification = {
    enable = true;
    name = "Tom Carrio";
    email = "tom@carrio.dev";
  };
}
