{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.oxc.endcord;

  endcordPkg =
    if cfg.enableMedia then
      cfg.package.override { withMedia = true; }
    else
      cfg.package;

  toPyValue = v:
    if v == null then "None"
    else if v == true then "True"
    else if v == false then "False"
    else if builtins.isInt v then toString v
    else if builtins.isFloat v then toString v
    else if builtins.isString v then
      let escaped = builtins.replaceStrings ["\\"] ["\\\\"] v;
      in "\"${escaped}\""
    else if builtins.isList v then
      "[${lib.concatStringsSep ", " (map toPyValue v)}]"
    else throw "endcord: cannot serialize ${builtins.typeOf v}";

  filterNulls = lib.filterAttrs (_: v: v != null);

  toEndcordINI = sections:
    let
      mkSection = name: values:
        let filtered = filterNulls values;
        in
        if filtered == { } then ""
        else "[${name}]\n" + lib.concatStringsSep "\n" (
          lib.mapAttrsToList (k: v: "${k} = ${toPyValue v}") filtered
        );
      parts = lib.filter (s: s != "") (lib.mapAttrsToList mkSection sections);
    in
    if parts == [ ] then "" else lib.concatStringsSep "\n\n" parts + "\n";

  mainConfig = filterNulls cfg.configuration.main;
  themeConfig = filterNulls cfg.configuration.theme;
  hasConfig = mainConfig != { } || themeConfig != { };

  inherit (lib.types)
    attrsOf
    bool
    float
    int
    listOf
    nullOr
    package
    str
    submodule
    unspecified
    ;

  mkOpt = type: desc: lib.mkOption {
    type = nullOr type;
    default = null;
    description = desc;
  };

  sectionType = options: submodule {
    freeformType = attrsOf unspecified;
    options = options;
  };

in
{
  options.oxc.endcord = {
    enable = lib.mkEnableOption "endcord Discord TUI client";

    package = lib.mkOption {
      type = package;
      default = pkgs.endcord;
      description = "The endcord package to use";
    };

    enableMedia = lib.mkOption {
      type = bool;
      default = true;
      description = "Whether to enable terminal ASCII media rendering support";
    };

    configuration = lib.mkOption {
      type = submodule {
        options = {
          main = lib.mkOption {
            type = sectionType {
              theme = mkOpt str "Custom theme path or name (default: None)";
              extensions = mkOpt bool "Enable extensions (default: True)";
              rpc = mkOpt bool "Enable RPC server (default: True)";
              game_detection = mkOpt bool "Enable game detection service (default: True)";
              vim_mode = mkOpt bool "Enable vim-like mode (default: False)";
              limit_chat_buffer = mkOpt int "Messages kept in chat buffer, 50-1000 (default: 100)";
              limit_channel_cache = mkOpt int "Previous channel chats kept in cache (default: 5)";
              download_msg = mkOpt int "Messages downloaded per chunk, 20-100 (default: 25)";
              convert_timezone = mkOpt bool "Use local time instead of UTC (default: True)";
              send_typing = mkOpt bool "Send typing indicator (default: True)";
              desktop_notifications = mkOpt bool "Send desktop notifications on ping (default: True)";
              notification_in_active = mkOpt bool "Notifications for mentions in active channel (default: True)";
              remove_previous_notification = mkOpt bool "Remove previous notification from same DM/channel (default: True)";
              ack_throttling = mkOpt int "Seconds between ack sends, min 3 (default: 5)";
              member_list = mkOpt bool "Download member activities (default: True)";
              member_list_auto_open = mkOpt bool "Auto-open member list on startup (default: False)";
              use_nick_when_available = mkOpt bool "Replace global_name with nick when available (default: True)";
              remember_state = mkOpt bool "Remember state across sessions (default: True)";
              remember_tabs = mkOpt bool "Remember tabbed channels across sessions (default: True)";
              reply_mention = mkOpt bool "Ping by default when replying (default: True)";
              cache_typed = mkOpt bool "Save unsent messages when switching channels (default: True)";
              show_pending_messages = mkOpt bool "Show pending messages in chat (default: True)";
              assist = mkOpt bool "Assist when typing @mentions, #channels, :emoji: (default: True)";
              cursor_on_time = mkOpt float "Seconds cursor stays ON (default: 0.7)";
              cursor_off_time = mkOpt float "Seconds cursor stays OFF (default: 0.5)";
              tab_spaces = mkOpt int "Spaces inserted on tab (default: 4)";
              blocked_mode = mkOpt int "Blocked message handling: 0=off, 1=mask, 2=hide (default: 2)";
              hide_spam = mkOpt bool "Hide spam DM requests (default: True)";
              keep_deleted = mkOpt bool "Keep deleted messages with different color (default: False)";
              limit_cache_deleted = mkOpt int "Cached deleted messages per channel (default: 30)";
              tree_show_folders = mkOpt bool "Show server folders in tree (default: True)";
              wrap_around = mkOpt bool "Wrap selection in tree and extra window (default: True)";
              mouse = mkOpt bool "Enable mouse controls (default: True)";
              mouse_scroll_sensitivity = mkOpt int "Lines scrolled per mouse scroll (default: 3)";
              mouse_scroll_selection = mkOpt bool "Scroll selection instead of content (default: False)";
              screen_update_delay = mkOpt float "Seconds before screen update, min 0.01 (default: 0.01)";
              extra_line_delay = mkOpt int "Seconds for temporary extra line pop-ups (default: 5)";
              tenor_gif_type = mkOpt int "Gif media type: 0=gif HD, 1=gif UHD, 2=mp4 (default: 1)";
              trim_embed_url_size = mkOpt int "Trim embed URL length, min 20 (default: 40)";
              aspell_mode = mkOpt str "Aspell filter mode: ultra/fast/normal/slow/bad-spellers or None (default: normal)";
              aspell_lang = mkOpt str "Aspell language dictionary (default: en_US)";
              media_mute = mkOpt bool "Mute video in media player (default: False)";
              media_cap_fps = mkOpt int "Max framerate for video playback (default: 30)";
              rpc_external = mkOpt bool "Use external resources for Rich Presence (default: True)";
              emoji_as_text = mkOpt bool "Convert emoji to names (default: False)";
              message_spacing = mkOpt bool "Space between messages from different users (default: True)";
              native_media_player = mkOpt bool "Use system media player instead of ASCII (default: False)";
              native_file_dialog = mkOpt str "File dialog: True/False/Auto (default: auto)";
              save_summaries = mkOpt bool "Save summaries to disk (default: True)";
              default_stickers = mkOpt bool "Download default Discord stickers (default: True)";
              only_one_open_server = mkOpt bool "Force only one open server in tree (default: False)";
              assist_skip_app_command = mkOpt bool "Skip assist for app_name in commands (default: False)";
              assist_limit = mkOpt int "Max assist results (default: 50)";
              assist_score_cutoff = mkOpt int "Assist match score cutoff (default: 15)";
              limit_command_history = mkOpt int "Max commands stored in history (default: 50)";
              game_detection_download_delay = mkOpt int "Days between game list updates (default: 7)";
              downloads_path = mkOpt str "Custom downloads directory (default: None)";
              notifications_pfp = mkOpt bool "Include profile pictures in notifications (default: True)";
              linux_notification_sound = mkOpt str "Linux notification sound name or None (default: message)";
              custom_notification_sound = mkOpt str "Path to custom notification sound or None (default: None)";
              linux_ringtone_incoming = mkOpt str "Linux incoming call sound name or None (default: phone-incoming-call)";
              custom_ringtone_incoming = mkOpt str "Path to incoming call audio or None (default: None)";
              linux_ringtone_outgoing = mkOpt str "Linux outgoing call sound name or None (default: phone-outgoing-calling)";
              custom_ringtone_outgoing = mkOpt str "Path to outgoing call audio or None (default: None)";
              custom_media_player = mkOpt str "Custom media player command or None (default: None)";
              custom_media_blacklist = mkOpt (listOf str) "Media types to ignore for custom player (default: None)";
              custom_media_terminal = mkOpt bool "Custom media player runs in terminal (default: False)";
              custom_media_hint = mkOpt bool "Pass media type as second arg to custom player (default: False)";
              external_editor = mkOpt str "External editor command or None (default: None)";
              calls = mkOpt bool "Enable receiving and starting calls (default: True)";
              yt_dlp_path = mkOpt str "Path to yt-dlp executable (default: yt-dlp)";
              yt_dlp_format = mkOpt int "yt-dlp format code for YouTube (default: 18)";
              mpv_path = mkOpt str "Path to mpv executable (default: mpv)";
              yt_in_mpv = mkOpt bool "Open YouTube links in mpv instead of browser (default: False)";
              check_for_updates = mkOpt int "Update check: 0=off, 1=popup, 2=popup+notify, 3=endcord only, 4=endcord+notify (default: 1)";
              check_update_interval = mkOpt int "Days between update checks (default: 1)";
              client_properties = mkOpt str "Client properties: default or anonymous (default: default)";
              custom_user_agent = mkOpt str "Custom user agent string or None (default: None)";
              send_x_super_properties = mkOpt bool "Send X-Super-Properties header (default: True)";
              proxy = mkOpt str "Proxy URL (protocol://host:port) or None (default: None)";
              custom_host = mkOpt str "Custom host to connect to or None (default: None)";
              capabilities = mkOpt int "Gateway capabilities/intents override or None (default: None)";
              easter_eggs = mkOpt bool "Enable easter eggs (default: True)";
              debug = mkOpt bool "Enable debug mode (default: False)";
            };
            default = { };
            description = "Main settings ([main] section of config.ini)";
          };

          theme = lib.mkOption {
            type = sectionType {
              compact = mkOpt bool "Compact space-efficient mode (default: False)";
              tree_width = mkOpt int "Channel tree width in characters (default: 32)";
              extra_window_height = mkOpt int "Extra window height above status line (default: 6)";
              member_list_width = mkOpt int "Member list width (default: 20)";
              format_message = mkOpt str "Message base format string (default: [%timestamp] <%global_name> | %content %edited)";
              format_newline = mkOpt str "Newline format string (default: with padding + %content)";
              format_reply = mkOpt str "Reply message format string";
              format_reactions = mkOpt str "Reactions format string";
              format_interaction = mkOpt str "App interaction format string";
              format_one_reaction = mkOpt str "Single reaction format string (default: %count:%reaction)";
              format_timestamp = mkOpt str "Timestamp format, Python datetime codes (default: %H:%M)";
              format_status_line_l = mkOpt str "Left status line format (default: with username, status, unreads)";
              format_status_line_r = mkOpt str "Right status line format (default: %vim_mode %slowmode)";
              format_title_line_l = mkOpt str "Left title line format (default: %server: %channel)";
              format_title_line_r = mkOpt str "Right title line format (default: %tabs)";
              format_title_tree = mkOpt str "Tree title line format (default: %app_name %task)";
              format_rich = mkOpt str "Rich presence format (default: %type %name - %state - %details)";
              format_tabs = mkOpt str "Tab format string (default: %num - %name)";
              format_prompt = mkOpt str "Prompt line format (default: [%channel] > )";
              format_forum = mkOpt str "Forum thread format (default: [%timestamp] - <%msg_count> - %thread_name)";
              format_forum_timestamp = mkOpt str "Forum timestamp format (default: %Y-%m-%d)";
              format_search_message = mkOpt str "Search result message format";
              edited_string = mkOpt str "String replacing %edited for edited messages (default: (edited))";
              app_string = mkOpt str "String replacing %app for app/webhook messages";
              quote_character = mkOpt str "Character prepended to quoted lines (default: ║)";
              reactions_separator = mkOpt str "String between reactions (default: ; )";
              tabs_separator = mkOpt str "String between tabs (default:  | )";
              chat_date_separator = mkOpt str "Character for day separator line or None (default: ─)";
              format_date = mkOpt str "Date format in separator (default:  %B %d, %Y )";
              limit_username = mkOpt int "Max username and global_name length (default: 10)";
              limit_channel_name = mkOpt int "Max channel name length (default: 15)";
              limit_typing_string = mkOpt int "Max typing string and rich presence length (default: 30)";
              limit_prompt = mkOpt int "Max prompt string length (default: 15)";
              limit_thread_name = mkOpt int "Max thread name length in prompt (default: 0)";
              limit_tab_len = mkOpt int "Max individual tab length (default: 12)";
              limit_tabs_string = mkOpt int "Max total tabs string length (default: 60)";
              tree_drop_down_vline = mkOpt str "Vertical line character in tree (default: │)";
              tree_drop_down_hline = mkOpt str "Horizontal line character in tree (default: ─)";
              tree_drop_down_intersect = mkOpt str "Intersection character in tree (default: ├)";
              tree_drop_down_corner = mkOpt str "Corner character in tree (default: ╰)";
              tree_drop_down_pointer = mkOpt str "Pointer character in tree (default: 🡲)";
              tree_drop_down_thread = mkOpt str "Thread pointer character (default: ⤙)";
              tree_drop_down_forum = mkOpt str "Forum pointer character (default: ◆)";
              tree_drop_down_folder = mkOpt str "Folder pointer character (default: +)";
              tree_dm_status = mkOpt str "DM status indicator character (default: ●)";
              border_corners = mkOpt str "Corner characters string for bordered mode (default: ╭╰╮╯)";
              username_role_colors = mkOpt bool "Color usernames by primary role (default: True)";
              dynamic_name_len = mkOpt bool "Dynamic name length in format_message (default: False)";
              media_use_blocks = mkOpt bool "Use block characters for media rendering (default: True)";
              media_truecolor = mkOpt bool "Truecolor for media rendering (default: True)";
              media_ascii_palette = mkOpt str "ASCII characters for media, darkest to brightest (default: '  ..',;:c*loexk#O0XNW')";
              media_saturation = mkOpt float "Saturation correction for media (default: 1.2)";
              media_font_aspect_ratio = mkOpt float "Font height/width ratio for media (default: 2.25)";
              media_color_bg = mkOpt int "Background color for media display (default: 16)";
              media_bar_ch = mkOpt str "Progress bar character for media player (default: ━)";
              color_default = mkOpt unspecified "Base color [fg, bg] or None (default: [-1, -1])";
              color_chat_mention = mkOpt unspecified "Mentioned message color (default: [223, 234])";
              color_chat_blocked = mkOpt unspecified "Blocked message color (default: [242, -1])";
              color_chat_deleted = mkOpt unspecified "Deleted message color (default: [95, -1])";
              color_chat_pending = mkOpt unspecified "Pending message color (default: [242, -1])";
              color_chat_selected = mkOpt unspecified "Selected line color (default: [233, 255])";
              color_chat_separator = mkOpt unspecified "Date separator color (default: [242, -1, i])";
              color_status_line = mkOpt unspecified "Status line color (default: [233, 255])";
              color_extra_line = mkOpt unspecified "Extra line color (default: [233, 245])";
              color_title_line = mkOpt unspecified "Title line color (default: [233, 255])";
              color_extra_window = mkOpt unspecified "Extra window body color (default: [-1, -1])";
              color_prompt = mkOpt unspecified "Prompt line color (default: [255, -1])";
              color_input_line = mkOpt unspecified "Input line base color (default: [255, -1])";
              color_cursor = mkOpt unspecified "Cursor color (default: [233, 255])";
              color_misspelled = mkOpt unspecified "Misspelled word color (default: [222, -1])";
              color_tree_default = mkOpt unspecified "Tree base color (default: [255, -1])";
              color_tree_selected = mkOpt unspecified "Tree selected item color (default: [233, 255])";
              color_tree_muted = mkOpt unspecified "Tree muted item color (default: [242, -1])";
              color_tree_active = mkOpt unspecified "Tree active item color (default: [255, 234])";
              color_tree_unseen = mkOpt unspecified "Tree unseen item color (default: [255, -1, b])";
              color_tree_mentioned = mkOpt unspecified "Tree mentioned item color (default: [197, -1])";
              color_tree_active_mentioned = mkOpt unspecified "Tree active+mentioned color (default: [197, 234])";
              color_format_message = mkOpt unspecified "Color format for message base string";
              color_format_newline = mkOpt unspecified "Color format for newline strings or None (default: None)";
              color_format_reply = mkOpt unspecified "Color format for reply strings";
              color_format_reactions = mkOpt unspecified "Color format for reaction strings";
              color_format_interaction = mkOpt unspecified "Color format for interaction strings";
              color_format_forum = mkOpt unspecified "Color format for forum threads";
              color_chat_standout = mkOpt unspecified "Standout elements color (default: [153, 234])";
              color_chat_edited = mkOpt unspecified "Edited string color (default: [241, -1])";
              color_chat_url = mkOpt unspecified "URL color (default: [153, -1, u])";
              color_chat_spoiler = mkOpt unspecified "Spoiler color (default: [245, -1])";
              color_chat_code = mkOpt unspecified "Code block color (default: [250, 233])";
            };
            default = { };
            description = "Theme settings ([theme] section of config.ini)";
          };
        };
      };
      default = { };
      description = "Configuration written to $XDG_CONFIG_DIR/endcord/config.ini";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ endcordPkg ];

    xdg.configFile."endcord/config.ini" = lib.mkIf hasConfig {
      text = toEndcordINI { main = mainConfig; theme = themeConfig; };
    };
  };
}
