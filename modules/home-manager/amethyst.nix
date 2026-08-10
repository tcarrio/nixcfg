{ lib, config, ... }:
let
  default = {
    # Default settings for Amethyst
    # Repo: `https://github.com/ianyh/Amethyst`
    #
    # Note due to issue 1419 (https://github.com/ianyh/Amethyst/issues/1419) some
    # config values may conflict and not work if they are the same as the default
    # values for Amethyst. You can see these values on GitHub at
    # https://github.com/ianyh/Amethyst/blob/development/Amethyst/default.amethyst
    # If you're experiencing conflicts and the settings are the same as the default,
    # comment out the commands in this file.
    #
    # Move this file to: `~/.amethyst.yml`
    # In order to register changes restart Amethyst.
    # If you experience issues pulling in the changes you can also quit Amethyst and run: `defaults delete com.amethyst.Amethyst.plist`
    # This removes the current preferences and causes Amethyst to restart with default preferences and pull configs from this file.

    # layouts - Ordered list of layouts to use by layout key (default tall, wide, fullscreen, and column).
    layouts = [
      "tall"
      "fullscreen"
      # "tall-right"
      "wide"
      # "two-pane"
      # "middle-wide"
      # "3column-left"
      # "middle-wide" # The legacy name of "3column-middle"
      # "3column-right"
      # "4column-left"
      # "4column-right"
      "column"
      # "row"
      # "floating"
      # "widescreen-tall"
      # "widescreen-tall-right"
      # "bsp"
    ];

    # First mod (default option + shift).
    mod1 = [
      "option"
      "shift"
      # "control"
      # "command"
    ];

    # Second mod (default option + shift + control).
    mod2 = [
      "option"
      "shift"
      "control"
      # "command"
    ];

    # Commands:
    # special key values
    # space
    # enter
    # up
    # right
    # down
    # left

    # special characters require quotes
    # '.'
    # ','

    # Move to the next layout in the list.
    cycle-layout = {
      mod = "mod1";
      key = "space";
    };

    # Move to the previous layout in the list.
    cycle-layout-backward = {
      mod = "mod2";
      key = "space";
    };

    # Shrink the main pane by a percentage of the screen dimension as defined by window-resize-step. Note that not all layouts respond to this command.
    shrink-main = {
      mod = "mod1";
      key = "h";
    };

    # Expand the main pane by a percentage of the screen dimension as defined by window-resize-step. Note that not all layouts respond to this command.
    expand-main = {
      mod = "mod1";
      key = "l";
    };

    # Increase the number of windows in the main pane. Note that not all layouts respond to this command.
    increase-main = {
      mod = "mod1";
      key = ",";
    };

    # Decrease the number of windows in the main pane. Note that not all layouts respond to this command.
    decrease-main = {
      mod = "mod1";
      key = ".";
    };

    # General purpose command for custom layouts. Functionality is layout-dependent.
    # command1:
    #   mod: <NONE>
    #   key: <NONE>
    # General purpose command for custom layouts. Functionality is layout-dependent.
    # command2:
    #   mod: <NONE>
    #   key: <NONE>
    # General purpose command for custom layouts. Functionality is layout-dependent.
    # command3:
    #   mod: <NONE>
    #   key: <NONE>
    # General purpose command for custom layouts. Functionality is layout-dependent.
    # command4:
    #   mod: <NONE>
    #   key: <NONE>

    # Focus the next window in the list going counter-clockwise.
    focus-ccw = {
      mod = "mod1";
      key = "j";
    };

    # Focus the next window in the list going clockwise.
    focus-cw = {
      mod = "mod1";
      key = "k";
    };

    # Focus the main window in the list.
    focus-main = {
      mod = "mod1";
      key = "m";
    };

    # Focus the next screen in the list going counter-clockwise.
    focus-screen-ccw = {
      mod = "mod1";
      key = "p";
    };

    # Focus the next screen in the list going clockwise.
    focus-screen-cw = {
      mod = "mod1";
      key = "n";
    };

    # Move the currently focused window onto the next screen in the list going counter-clockwise.
    swap-screen-ccw = {
      mod = "mod2";
      key = "h";
    };

    # Move the currently focused window onto the next screen in the list going clockwise.
    swap-screen-cw = {
      mod = "mod2";
      key = "l";
    };

    # Swap the position of the currently focused window with the next window in the list going counter-clockwise.
    swap-ccw = {
      mod = "mod2";
      key = "j";
    };

    # Swap the position of the currently focused window with the next window in the list going clockwise.
    swap-cw = {
      mod = "mod2";
      key = "k";
    };

    # Swap the position of the currently focused window with the main window in the list.
    swap-main = {
      mod = "mod1";
      key = "enter";
    };

    # Move focus to the n-th screen in the list; e.g., focus-screen-3 will move mouse focus to the 3rd screen. Note that the main window in the given screen will be focused.
    #focus-screen-n:
    # focus-screen-<screen-number>:
    #   mod: mod1
    #   key: y
    # Move the currently focused window to the n-th screen; e.g., throw-screen-3 will move the window to the 3rd screen.
    # throw-screen-n:
    # throw-screen-<screen-number>:
    #   mod: mod1
    #   key: u
    # Move the currently focused window to the n-th space; e.g., throw-space-3 will move the window to the 3rd space.
    # throw-space-<screen-number>:
    #   mod: mod1
    #   key: i

    # Select tall layout
    select-tall-layout = {
      mod = "mod1";
      key = "a";
    };

    # Select wide layout
    select-wide-layout = {
      mod = "mod1";
      key = "s";
    };

    # Select fullscreen layout
    select-fullscreen-layout = {
      mod = "mod1";
      key = "d";
    };

    # Select column layout
    select-column-layout = {
      mod = "mod1";
      key = "f";
    };

    # Move the currently focused window to the space to the left.
    throw-space-left = {
      mod = "mod2";
      key = "left";
    };

    # Move currently the focused window to the space to the right.
    throw-space-right = {
      mod = "mod2";
      key = "right";
    };

    # Toggle the floating state of the currently focused window; i.e., if it was floating make it tiled and if it was tiled make it floating.
    toggle-float = {
      mod = "mod1";
      key = "t";
    };

    # Display the layout HUD with the current layout on each screen.
    display-current-layout = {
      mod = "mod1";
      key = "i";
    };

    # Turn on or off tiling entirely.
    toggle-tiling = {
      mod = "mod2";
      key = "t";
    };

    # Turn on tiling.
    # enable-tiling:
    #   mod: mod2
    #   key: <NONE>

    # Turn off tiling.
    # disable-tiling:
    #   mod: mod2
    #   key: <NONE>

    # Rerun the current layout's algorithm.
    reevaluate-windows = {
      mod = "mod1";
      key = "z";
    };

    # Turn on or off focus-follows-mouse.
    toggle-focus-follows-mouse = {
      mod = "mod2";
      key = "x";
    };

    # Automatically quit and reopen Amethyst.
    relaunch-amethyst = {
      mod = "mod2";
      key = "z";
    };

    # disable screen padding on builtin display
    disable-padding-on-builtin-display = false;

    # Boolean flag for whether or not to add margins between windows (default false).
    # Left off globally so margins are a property of the ring-light layout rather
    # than something every layout pays for.
    window-margins = false;

    # Boolean flag for whether or not to set window margins if there is only one window on the screen, assuming window margins are enabled (default false).
    smart-window-margins = false;

    # # Add 10px margin between windows
    # window-margins: true
    # window-margin-size: 5
    # The size of the margins between windows (in px, default 0).
    window-margin-size = 0;

    # The max number of windows that may be visible on a screen at one time before
    # additional windows are minimized. A value of 0 disables the feature.
    window-max-count = 0;

    # The smallest height that a window can be sized to regardless of its layout frame (in px, default 0).
    window-minimum-height = 0;

    # The smallest width that a window can be sized to regardless of its layout frame (in px, default 0)
    window-minimum-width = 0;

    # List of bundle identifiers for applications to either be automatically floating or automatically tiled based on floating-is-blacklist (default []).
    floating = [ ];

    # Boolean flag determining behavior of the floating list. true if the applications should be floating and all others tiled. false if the applications should be tiled and all others floating (default true).
    floating-is-blacklist = true;

    # true if screen frames should exclude the status bar. false if the screen frames should include the status bar (default false).
    ignore-menu-bar = false;

    # true if menu bar icon should be hidden (default false).
    hide-menu-bar-icon = false;

    # true if windows smaller than a 500px square should be floating by default (default true)
    float-small-windows = true;

    # true if the mouse should move position to the center of a window when it becomes focused (default false). Note that this is largely incompatible with focus-follows-mouse.
    mouse-follows-focus = false;

    # true if the windows underneath the mouse should become focused as the mouse moves (default false). Note that this is largely incompatible with mouse-follows-focus
    focus-follows-mouse = false;

    # true if dragging and dropping windows on to each other should swap their positions (default false).
    mouse-swaps-windows = false;

    # true if changing the frame of a window with the mouse should update the layout to accommodate the change (default false). Note that not all layouts will be able to respond to the change.
    mouse-resizes-windows = false;

    # true to display the name of the layout when a new layout is selected (default true).
    enables-layout-hud = true;

    # true to display the name of the layout when moving to a new space (default true).
    enables-layout-hud-on-space-change = true;

    # true to get updates to beta versions of the software (default false).
    use-canary-build = false;

    # true to insert new windows into the first position and false to insert new windows into the last position (default false).
    new-windows-to-main = false;

    # true to automatically move to a space when throwing a window to it (default true).
    follow-space-thrown-windows = true;

    # The integer percentage of the screen dimension to increment and decrement main pane ratios by (default 5).
    window-resize-step = 5;

    # Padding to apply between windows and the left edge of the screen (in px, default 0).
    screen-padding-left = 0;

    # Padding to apply between windows and the right edge of the screen (in px, default 0).
    screen-padding-right = 0;

    # Padding to apply between windows and the top edge of the screen (in px, default 0).
    screen-padding-top = 0;

    # Padding to apply between windows and the bottom edge of the screen (in px, default 0).
    screen-padding-bottom = 0;

    # true to maintain layout state across application executions (default true).
    restore-layouts-on-launch = true;

    # true to display some optional debug information in the layout HUD (default false).
    debug-layout-info = false;
  };

  inherit (lib)
    types
    mkEnableOption
    mkOption
    mkIf
    ;

  baseSettings = if cfg.defaults then default else { };

  settings = baseSettings // cfg.settings;

  cfg = config.oxc.amethyst;

  # Amethyst custom layouts are picked up from this directory and keyed by file
  # name, so `ring-light.js` becomes the layout key `ring-light` (usable in the
  # `layouts` list and as the `select-ring-light-layout` command).
  layoutsDir = "Library/Application Support/Amethyst/Layouts";

  # Whatever frames a layout hands back, Amethyst insets by
  # `floor(window-margin-size / 2)` on every side before applying them
  # (`FrameAssignment.finalFrame`). Subtracting that here is what makes the
  # configured padding the number that actually lands on screen.
  appliedMargin =
    if (settings.window-margins or false) then
      builtins.floor ((settings.window-margin-size or 0) / 2.0)
    else
      0;

  # A tall layout that keeps a wide, even border of desktop visible around the
  # tiled windows, so a bright wallpaper acts as a fill light on video calls.
  ringLightLayout = with cfg.ringLight; ''
    // Generated from modules/home-manager/amethyst.nix — edit the Nix module.
    function layout() {
        // Border left between the outermost windows and each screen edge, in px.
        const PADDING = {
            top: ${toString padding.top},
            bottom: ${toString padding.bottom},
            left: ${toString padding.left},
            right: ${toString padding.right}
        };
        // Space left between two adjacent windows, in px.
        const GAP = ${toString gap};
        // Inset Amethyst applies to our frames on its own, in px.
        const APPLIED = ${toString appliedMargin};

        // Half the gap comes off each side of a window; the padding left over
        // once that is accounted for shrinks the region we tile into.
        const inset = Math.max(0, GAP / 2 - APPLIED);
        const edge = {
            top: Math.max(0, PADDING.top - GAP / 2),
            bottom: Math.max(0, PADDING.bottom - GAP / 2),
            left: Math.max(0, PADDING.left - GAP / 2),
            right: Math.max(0, PADDING.right - GAP / 2)
        };

        const step = ${toString ((settings.window-resize-step or 5) / 100.0)};

        return {
            name: "${name}",
            initialState: {
                mainPaneCount: 1,
                mainPaneRatio: 0.5
            },
            commands: {
                increaseMain: {
                    description: "Increase main pane count",
                    updateState: (state) => ({ ...state, mainPaneCount: state.mainPaneCount + 1 })
                },
                decreaseMain: {
                    description: "Decrease main pane count",
                    updateState: (state) => ({ ...state, mainPaneCount: Math.max(1, state.mainPaneCount - 1) })
                },
                shrinkMain: {
                    description: "Shrink the main pane",
                    updateState: (state) => ({ ...state, mainPaneRatio: Math.max(step, state.mainPaneRatio - step) })
                },
                expandMain: {
                    description: "Expand the main pane",
                    updateState: (state) => ({ ...state, mainPaneRatio: Math.min(1 - step, state.mainPaneRatio + step) })
                }
            },
            recommendMainPaneRatio: (ratio, state) => ({ ...state, mainPaneRatio: ratio }),
            getFrameAssignments: (windows, screenFrame, state) => {
                const area = {
                    x: screenFrame.x + edge.left,
                    y: screenFrame.y + edge.top,
                    width: Math.max(1, screenFrame.width - edge.left - edge.right),
                    height: Math.max(1, screenFrame.height - edge.top - edge.bottom)
                };

                const mainCount = Math.min(state.mainPaneCount, windows.length);
                const secondaryCount = windows.length - mainCount;
                const hasSecondary = secondaryCount > 0;

                const mainWidth = hasSecondary ? area.width * state.mainPaneRatio : area.width;
                const mainHeight = area.height / mainCount;
                const secondaryHeight = hasSecondary ? area.height / secondaryCount : 0;

                return windows.reduce((frames, window, index) => {
                    const isMain = index < mainCount;
                    const frame = isMain
                        ? {
                            x: area.x,
                            y: area.y + mainHeight * index,
                            width: mainWidth,
                            height: mainHeight
                        }
                        : {
                            x: area.x + mainWidth,
                            y: area.y + secondaryHeight * (index - mainCount),
                            width: area.width - mainWidth,
                            height: secondaryHeight
                        };

                    return {
                        ...frames,
                        [window.id]: {
                            x: frame.x + inset,
                            y: frame.y + inset,
                            width: Math.max(1, frame.width - 2 * inset),
                            height: Math.max(1, frame.height - 2 * inset),
                            isMain: isMain,
                            unconstrainedDimension: "horizontal"
                        }
                    };
                }, {});
            }
        };
    }
  '';
in
{
  options.oxc.amethyst = {
    enable = mkEnableOption "amethyst";
    settings = mkOption {
      inherit default;
      type = types.attrs;
    };
    defaults = mkEnableOption "Extend default settings";

    layouts = mkOption {
      type = types.attrsOf types.lines;
      default = { };
      example = lib.literalExpression ''
        {
          "uniform-columns" = builtins.readFile ./uniform-columns.js;
        }
      '';
      description = ''
        Custom Amethyst layouts, keyed by layout key. Each value is the
        JavaScript source of a layout, written to
        `~/${layoutsDir}/<key>.js`.

        The key is also what you list in `settings.layouts` and what the
        `select-<key>-layout` command is named after.
      '';
    };

    ringLight = {
      enable = mkEnableOption ''
        the "ring light" layout, a tall layout that leaves a wide border of
        desktop visible around the tiled windows so a bright wallpaper can act
        as a fill light on video calls
      '';

      key = mkOption {
        type = types.str;
        default = "ring-light";
        description = ''
          Layout key. Add this to `settings.layouts` to put the layout in the
          cycle, and bind `select-<key>-layout` to jump straight to it.
        '';
      };

      name = mkOption {
        type = types.str;
        default = "Ring Light";
        description = "Display name shown in the layout HUD.";
      };

      padding = mkOption {
        type = types.submodule {
          options =
            lib.genAttrs [ "top" "bottom" ] (
              side:
              mkOption {
                type = types.ints.unsigned;
                default = 96;
                description = "Width in px of the ring along the ${side} edge of the screen.";
              }
            )
            // lib.genAttrs [ "left" "right" ] (
              side:
              mkOption {
                type = types.ints.unsigned;
                # Widescreen displays have room to spare horizontally, and the
                # sides are what a camera actually sees light from.
                default = 192;
                description = "Width in px of the ring along the ${side} edge of the screen.";
              }
            );
        };
        default = { };
        description = ''
          Width in px of the border left between the tiled windows and each
          screen edge — the ring itself.
        '';
      };

      gap = mkOption {
        type = types.ints.unsigned;
        default = 48;
        description = "Space in px left between two adjacent windows.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.file = {
      "${config.xdg.configHome}/amethyst/amethyst.yml".text = lib.generators.toYAML { } settings;
    }
    // lib.mapAttrs' (
      key: text: lib.nameValuePair "${layoutsDir}/${key}.js" { inherit text; }
    ) cfg.layouts;

    oxc.amethyst.layouts = mkIf cfg.ringLight.enable {
      ${cfg.ringLight.key} = ringLightLayout;
    };
  };
}
