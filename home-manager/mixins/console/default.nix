# Console mixin: internal hosts enable the oxc console profile — the
# canonical composition now lives in the library (modules/.../profiles).
{ ... }:
{
  oxc.profiles.console.enable = true;
}
