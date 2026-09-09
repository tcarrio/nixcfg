{
  ...
}:
{
  # Desktop hosts opt out of the zed editor. The base profile's enable is
  # mkDefault, so this plain value simply overrides it; this file only
  # loads when the host has a desktop environment.
  oxc.zed-editor.enable = false;
}
