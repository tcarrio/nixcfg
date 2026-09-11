---
name: gnome-dconf-lookup
description: Lookup GNOME dconf/gsettings keys — schema, key, type, default, and possible values — from a Settings UI label, schema name, or key name. Use whenever configuring GNOME via dconf/home-manager/nixos and the key or its valid values are unknown.
---

# GNOME dconf/gsettings lookup

Find the exact settings key behind a GNOME toggle/label, its type, default,
and legal values. Report in the standard format at the end.

## Core facts about where schemas live

GNOME schemas are **per-component**, not centralized:

| Schema prefix | Source of truth |
|---|---|
| `org.gnome.desktop.*` | gitlab.gnome.org/GNOME/gsettings-desktop-schemas (`schemas/*.gschema.xml`) |
| `org.gnome.mutter` | gitlab.gnome.org/GNOME/mutter (`data/org.gnome.mutter.gschema.xml`) |
| `org.gnome.shell*` | gitlab.gnome.org/GNOME/gnome-shell (`data/*.gschema.xml`) |
| `org.gnome.Settings*` / panel keys | gitlab.gnome.org/GNOME/gnome-control-center |
| `org.gnome.settings-daemon.*` | gitlab.gnome.org/GNOME/gnome-settings-daemon |
| `org.gtk.*` / `org.gtk4.*` | GTK itself (settings schema in GTK source) |
| `desktop/ibus/*` | ibus |
| anything else | grep the UI label across GNOME GitLab to find the owner (next section) |

gsettings-desktop-schemas is ONLY the shared desktop subset — do not assume
a key lives there.

## Lookup procedure (in order)

### 1. Label → key: find the owning component

When starting from a Settings UI label (e.g. "Workspaces on primary display
only"), locate the gschema by searching the component sources. Best queries:

- GitLab code search: `https://gitlab.gnome.org/search?search=<label>&group_id=8&project_id=...`
  (group 8 = GNOME) — or use a code search engine indexing GNOME GitLab
  (grep.app with `repo:` filters rarely covers GNOME; prefer GitLab search or
  GitHub mirrors `github:GNOME/<component>`).
- The Settings UI panels are defined in gnome-control-center under
  `panels/<panel>/`; the panel source binds widgets to keys — searching the
  label text there yields the key directly.
- The `<summary>` and `<description>` strings in .gschema.xml files
  frequently match (or translate) the UI label — searching for the label
  across `*.gschema.xml` files is the highest-signal query.

### 2. Key → definition: read the gschema

Fetch the `.gschema.xml` from the owning repo (raw file URL). The entry
gives everything:

```xml
<key type="b" name="workspaces-only-on-primary">
  <default>false</default>
  <summary>Workspaces only on primary display</summary>
  <description>...</description>
</key>
```

- `type`: `b` bool, `i` int32, `u` uint32, `s` string, `as` string array,
  `ai` int array, `(ii)` tuples, `d` double
- enums appear as `<choice value='...'>` lists — those are the possible
  values; flags similarly with `<choice>` inside a flags type

### 3. Verify at runtime (when on the machine, prefer this over docs)

```sh
gsettings list-schemas | grep -i <topic>          # find the schema name
gsettings list-recursively org.gnome.mutter       # all keys + current values
gsettings range org.gnome.mutter workspaces-only-on-primary   # type/enum values
gsettings describe org.gnome.mutter workspaces-only-on-primary # per-key docs
gsettings get org.gnome.mutter workspaces-only-on-primary      # current value
```

`gsettings range` prints `type b` for booleans, or `enum` + the value list
for enums — authoritative possible-values. Requires the schema installed
locally (any GNOME machine; or `nix shell nixpkgs#glib` plus the relevant
`gsettings-desktop-schemas`/component for schema-only lookups).

dconf path = schema with dots → slashes, key appended:
`org.gnome.mutter` + `workspaces-only-on-primary` →
`/org/gnome/mutter/workspaces-only-on-primary`.

## Output format

Always conclude with this block:

```
schema:  org.gnome.<component>[.<sub>]
key:     <key>
dconf:   /org/gnome/.../<key>
type:    <b|i|u|s|as|enum...>
default: <default from gschema>
values:  <enum choices or n/a for booleans — state true/false meaning>
set:     dconf write <dconf-path> <value>
         gsettings set <schema> <key> <value>
nix:     dconf.settings."org/gnome/<component>".<key> = <value>;
```

For booleans, state what true AND false each mean (defaults are often the
unwanted direction). For home-manager, values needing GVariant types (tuples,
arrays) use `lib.hm.gvariant` (e.g. `mkUint32`, `mkTuple`).

## Worked example

"Multi-monitor > Workspaces on primary display only" (GNOME 46 Settings →
Multitasking) → owned by mutter:

```
schema:  org.gnome.mutter
key:     workspaces-only-on-primary
dconf:   /org/gnome/mutter/workspaces-only-on-primary
type:    b
default: false (workspaces span all displays)
values:  true = primary display only; false = all displays
set:     dconf write /org/gnome/mutter/workspaces-only-on-primary true
nix:     dconf.settings."org/gnome/mutter".workspaces-only-on-primary = true;
```
