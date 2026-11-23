{
    config,
    lib,
    pkgs,
    ...
}:
let
    cfg         = config.userSettings.hyprland;
    browser     = config.userSettings.browser;
    terminal    = config.userSettings.terminal;
    spotify     = config.userSettings.spotify;
    vicinae     = config.userSettings.vicinae;
    editor      = config.userSettings.editor;
    laptop      = config.userSettings.laptop;
    mainMonitor = config.userSettings.mainMonitor;

    themes = import ./themes.nix;

    shader_path    = ".config/hypr/shaders/vibrance.glsl";
    disable_shader = ''hyprctl eval \"hl.config({ decoration = { screen_shader = \'\' }})\";'';
    enable_shader  = ''hyprctl eval \"hl.config({ decoration = { screen_shader = \'~/${shader_path}\' } })\";'';

    lua  = lib.generators.mkLuaInline;

    bind = key: action: {
        _args = [
            key
            (lua action)
        ];
    };

    focus = ws:
        ''hl.dsp.focus({ workspace = "${toString ws}"})'';

    move = ws:
        ''hl.dsp.window.move({ workspace = "${toString ws}"})'';

    on = event: body: {
        _args = [
            event
            (lua ''
                function()
                    ${lib.concatStringsSep "\n" body}
                end
            '')
        ];
    };

    exec = cmd:
        ''hl.dsp.exec_cmd("${cmd}")'';

    exec-once = cmd: { workspace ? null }:
        if workspace == null
        then ''hl.exec_cmd("${cmd}")''
        else ''hl.exec_cmd("${cmd}", { workspace = "${workspace}" })'';

    env = lib.mapAttrsToList (key: value: {
        _args = [
            key
            value
        ];
    });

    mod          = "SUPER";
    rotate_value = 100;

    dropNulls = lib.filterAttrs (_: v: v != null);

    luaTable = attrs:
        lib.generators.toLua { multiline = false; } (dropNulls attrs);

    call = path: args:
        let
            filtered = dropNulls args;
            body     = if filtered == {} then "" else luaTable filtered;
        in
        "hl.dsp.${path}(${body})";

    hl = {
        bind = key: action: flags: {
            _args = [
                key
                (lua action)
                flags
            ];
        };
        dsp = {
            focus = { direction }:
                call "focus" { inherit direction; };
            window = {
                fullscreen = { action ? null, mode ? null }:
                    call "window.fullscreen" { inherit action mode; };

                float = { action ? null }:
                    call "window.float" { inherit action; };

                resize = { x ? null, y ? null, relative ? null}:
                    call "window.resize" { inherit x y relative; };

                close = { window ? null}:
                    call "window.close" { inherit window; };

                kill = { window ? null}:
                    call "window.kill" { inherit window; };

                drag = "hl.dsp.window.drag()";
            };
        };
    };
in
{
    options = {
        userSettings.hyprland = {
            enable = lib.mkEnableOption "Enables Hyprland";
            nvidia = lib.mkEnableOption "Enables Nvidia for Hyprland";
            config = lib.mkOption {
                type = lib.types.attrs;
                default = {};
                description = "Adds configuration to Hyprland";
            };
        };

        userSettings.mainMonitor = lib.mkOption {
            type        = lib.types.str;
            description = "Main monitor";
        };

        userSettings.laptop = lib.mkEnableOption "Enable Laptop Settings";
    };

    config = lib.mkIf cfg.enable {
        wayland.windowManager.hyprland.enable = true;

        home.packages = with pkgs; [
            hyprpicker
            hyprshot

            playerctl
            brightnessctl

            (writeShellScriptBin "change-wallpaper" ''
            if [ -z "$1" ]; then
                echo "Usage: change-wallpaper <path>"
                exit 1
            fi

            Wallpaper=$(realpath "$1")

            if [ ! -f "$Wallpaper" ]; then
                echo "ERROR: File not found: $Wallpaper"
                exit 1
            fi

            cat > ~/.config/hypr/hyprpaper.conf << EOF
            splash = false;
            wallpaper {
                      monitor = ${mainMonitor}
                      path    = $Wallpaper
            }
            EOF
            hyprctl hyprpaper wallpaper "${mainMonitor}, $Wallpaper"
            '')
        ];

        wayland.windowManager.hyprland.configType = "lua";
        wayland.windowManager.hyprland.settings = lib.mkMerge [
            {
                config = {
                    cursor.hide_on_key_press = true;

                    input = {
                        force_no_accel = true;
                        follow_mouse = 1;
                        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
                        kb_layout = "us,us";
                        kb_variant = ",intl";
                    };

                    general.layout = "master";

                    dwindle = {
                        # TODO: This is broken
                        # pseudotile = true;
                        preserve_split = true;
                        force_split = 2; # Always split to the right
                    };

                    master = {
                        new_status = "slave";
                        mfact      = 0.50;
                    };

                    decoration.screen_shader = "~/${shader_path}";

                    misc = {
                        key_press_enables_dpms = true;
                        force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
                        disable_hyprland_logo = true; # If true disables the random hyprland logo / anime girl background. :(
                    };
                };

                # From Hyprland docs
                window_rule = [
                    {
                        # Ignore maximize requests from all apps. You'll probably like this.
                        name           = "suppress-maximize-events";
                        match.class    = ".*";
                        suppress_event = "maximize";
                    }
                    {
                        # Fix some dragging issues with XWayland
                        name = "fix-xwayland-drags";
                        match = {
                            class      = "^$";
                            title      = "^$";
                            xwayland   = true;
                            float      = true;
                            fullscreen = false;
                            pin        = false;
                        };
                        no_focus = true;
                    }
                    {
                        # Hyprland-run windowrule
                        name        = "move-hyprland-run";
                        match.class = "hyprland-run";
                        move        = "20 monitor_h-120";
                        float       = true;
                    }
                ];

                on = [
                    (on "hyprland.start" (
                        [
                            (exec-once browser { workspace = "1 silent"; })
                            (exec-once (if editor != "emacs" then terminal else editor) { workspace = "3 silent"; })
                        ]
                        ++ lib.optional spotify.enable (exec-once "spotify" { workspace = "4 silent"; })
                    ))
                ];

                bind = [
                    (bind "${mod} + T" (exec terminal))
                    (bind "${mod} + B" (exec browser))
                    (bind "${mod} + Q" (hl.dsp.window.close {}))
                    (bind "${mod} + SHIFT + Q" (hl.dsp.window.kill {}))
                    (bind "${mod} + V" (hl.dsp.window.float { action = "toggle"; }))
                    (bind "${mod} + F" (hl.dsp.window.fullscreen { action = "toggle"; mode = "maximized"; }))
                    (bind "${mod} + SHIFT + F" (hl.dsp.window.fullscreen { action = "toggle"; mode = "fullscreen"; }))

                    (bind "${mod} + H" (hl.dsp.focus { direction = "left"; }))
                    (bind "${mod} + J" (hl.dsp.focus { direction = "down"; }))
                    (bind "${mod} + K" (hl.dsp.focus { direction = "up"; }))
                    (bind "${mod} + L" (hl.dsp.focus { direction = "right"; }))

                    (bind "${mod} + SHIFT + H" (hl.dsp.window.resize { x = -rotate_value; y = 0; relative = true; }))
                    (bind "${mod} + SHIFT + J" (hl.dsp.window.resize { x = 0; y = rotate_value; relative = true; }))
                    (bind "${mod} + SHIFT + K" (hl.dsp.window.resize { x = 0; y = -rotate_value; relative = true; }))
                    (bind "${mod} + SHIFT + L" (hl.dsp.window.resize { x = rotate_value; y = 0; relative = true; }))

                    (bind "${mod} + SHIFT + E" (exec "${disable_shader} hyprpicker --autocopy --lowercase-hex; ${enable_shader}"))
                    (bind "${mod} + S" (exec "hyprshot -m window"))
                    (bind "${mod} + SHIFT + S" (exec "hyprshot -m region"))
                    (bind "${mod} + CTRL + S" (exec "hyprshot -m output -m active"))
                    (bind "${mod} + TAB" (exec "hyprctl switchxkblayout current next"))

                    # NOTE: Left: 272, Right: 273, Middle: 274
                    (bind "${mod} + mouse:272" hl.dsp.window.drag)
                    (bind "${mod} + mouse:273" (hl.dsp.window.resize {}))

                    (hl.bind "${mod} + Z" (exec "playerctl previous") { repeating = true; })
                    (hl.bind "${mod} + X" (exec "playerctl next") { repeating = true; })
                    (bind "${mod} + SHIFT + A" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
                    (bind "${mod} + A" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
                ]
                ++ map(n: bind "${mod} + ${toString n}" (focus n)) (lib.range 0 9)
                ++ map(n: bind "${mod} + SHIFT + ${toString n}" (move n)) (lib.range 0 9)
                ++ lib.optional vicinae.enable (bind "${mod} + SPACE" (exec "vicinae toggle"))
                ++ lib.optionals spotify.enable [
                    (bind "${mod} + C" (exec "playerctl play-pause --player spotify"))
                    (hl.bind "${mod} + SHIFT + Z" (exec "playerctl volume 0.1- --player spotify") { repeating = true; })
                    (hl.bind "${mod} + SHIFT + X" (exec "playerctl volume 0.1+ --player spotify") { repeating = true; })
                ];
            }

            # Add Nvidia config if necessary
            (lib.mkIf cfg.nvidia {
                env = env {
                    LIBVA_DRIVER_NAME            = "nvidia";
                    __GLX_VENDOR_LIBRARY_NAME    = "nvidia";
                    NVD_BACKEND                  = "direct";
                    # Electron
                    ELECTRON_OZONE_PLATFORM_HINT = "auto";
                    NIXOS_OZONE_WL               = 1;
                };

                config = {
                    cursor.no_hardware_cursors = true;
                    misc.vrr = 1;
                };
            })

            (lib.mkIf laptop {
                bind = [
                    (hl.bind "XF86AudioRaiseVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+") { locked = true; repeating = true; })
                    (hl.bind "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") { locked = true; repeating = true; })
                    (hl.bind "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") { locked = true; repeating = true; })
                    (hl.bind "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") { locked = true; repeating = true; })
                    (hl.bind "XF86MonBrightnessUp" (exec "brightnessctl s 10%+") { locked = true; repeating = true; })
                    (hl.bind "XF86MonBrightnessDown" (exec "brightnessctl s 10%-") { locked = true; repeating = true; })
                    (hl.bind "pause" (exec "playerctl play-pause") { locked = true; })
                    # NOTE: Lock screen when closing laptop
                    (hl.bind "switch:Lid Switch" (exec "hyprlock") { locked = true; })
                ];
            })

            # Add extra config
            cfg.config
            themes.simple
        ];

        home.sessionVariables = {
            HYPRSHOT_DIR = "Pictures/screenshots";
        };

        programs.hyprlock.enable = true;
        programs.hyprlock.settings = {
            general = {
                hide_cursor = true;
            };

            background = {
                path = "screenshot";
                blur_passes = 3;
            };

            input-field = {
                size = "20%, 5%";
                outline_thickness = 1;
                rounding = 15;
                inner_color = "0xff${config.lib.stylix.colors.base00}";
                outer_color = "0xff454545";
                font_color = "0xff${config.lib.stylix.colors.base05}";
                placeholder_text = "";
                fade_timeout = 0;
            };
        };

        services.hyprpaper.enable = false;

        home.file."${shader_path}".text = ''
/*
* Vibrance
*
* Enhance color saturation.
* Also supports per-channel multipliers.
*
* Source: https://github.com/hyprwm/Hyprland/issues/1140#issuecomment-1614863627
*/
#version 300 es
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;
// see https://github.com/CeeJayDK/SweetFX/blob/a792aee788c6203385a858ebdea82a77f81c67f0/Shaders/Vibrance.fx#L20-L30
/**
* Per-channel multiplier to vibrance strength.
*
* @min 0.0
* @max 10.0
*/
const vec3 Balance = vec3(1.0, 1.0, 1.0);
/**
* Strength of filter.
* (Negative values will reduce vibrance.)
*
* @min -1.0
* @max 1.0
*/
const float Strength = 0.40;
const vec3 VIB_coeffVibrance = Balance * -Strength;
void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    vec3 color = pixColor.rgb;
    vec3 VIB_coefLuma = vec3(0.212656, 0.715158, 0.072186);
    float luma = dot(VIB_coefLuma, color);
    float max_color = max(color.r, max(color.g, color.b));
    float min_color = min(color.r, min(color.g, color.b));
    float color_saturation = max_color - min_color;
    vec3 p_col = (sign(VIB_coeffVibrance) * color_saturation - 1.0) * VIB_coeffVibrance + 1.0;
    vec3 adjustedColor = mix(vec3(luma), color, p_col);
    fragColor = vec4(adjustedColor, pixColor.a);
}
        '';
    };
}
