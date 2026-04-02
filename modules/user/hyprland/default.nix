{
    config,
    lib,
    pkgs,
    ...
}:
let
    cfg = config.userSettings.hyprland;
    browser = config.userSettings.browser;
    terminal = config.userSettings.terminal;
    spotify = config.userSettings.spotify;
    vicinae = config.userSettings.vicinae;
    editor = config.userSettings.editor;
    laptop = config.userSettings.laptop;

    themes = import ./themes.nix;

    shader_path = ".config/hypr/shaders/vibrance.glsl";
    disable_shader = "hyprctl keyword decoration:screen_shader '';";
    enable_shader = "hyprctl keyword decoration:screen_shader '~/${shader_path}'";
in
{
    options = {
        userSettings.hyprland = {
            enable = lib.mkEnableOption "Enables Hyprland";
            nvidia = lib.mkEnableOption "Enables Nvidia for Hyprland";
            config = lib.mkOption {
                type = lib.types.attrs;
                default = { };
                description = "Adds configuration to Hyprland";
            };
        };
    };

    config = lib.mkIf cfg.enable {
        wayland.windowManager.hyprland.enable = true;

        home.packages = with pkgs; [
            kitty

            hyprpicker
            hyprshot
            hyprlock

            playerctl
            brightnessctl
        ];

        wayland.windowManager.hyprland.settings = lib.mkMerge [
            {
                cursor = {
                    hide_on_key_press = true;
                };

                "$mainMod" = "SUPER";
                "$rotate_val" = 100;

                exec-once = [
                    "[workspace 1 silent] ${browser}"
                    "[workspace 3 silent] ${ if editor != "emacs" then terminal else editor }"
                ]
                ++ lib.optional spotify.enable "[workspace 4 silent] spotify";

                input = {
                    force_no_accel = true;
                    follow_mouse = 1;
                    sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

                    kb_layout = "us,us";
                    kb_variant = ",intl";
                };

                # From Hyprland docs
                windowrule = [
                    {
                        # Ignore maximize requests from all apps. You'll probably like this.
                        name = "suppress-maximize-events";
                        "match:class" = ".*";
                        suppress_event = "maximize";
                    }
                    {
                        # Fix some dragging issues with XWayland
                        name = "fix-xwayland-drags";
                        "match:class" = "^$";
                        "match:title" = "^$";
                        "match:xwayland" = true;
                        "match:float" = true;
                        "match:fullscreen" = false;
                        "match:pin" = false;
                        no_focus = true;
                    }
                    {
                        # Hyprland-run windowrule
                        name = "move-hyprland-run";
                        "match:class" = "hyprland-run";
                        move = "20 monitor_h-120";
                        float = "yes";
                    }
                ];

                dwindle = {
                    pseudotile = true;
                    preserve_split = true;
                    force_split = 2; # Always split to the right
                };

                master = {
                    new_status = "master";
                };

                misc = {
                    key_press_enables_dpms = true;
                    force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
                    disable_hyprland_logo = true; # If true disables the random hyprland logo / anime girl background. :(
                };

                bind = [
                    "$mainMod, T, exec, ${terminal}"
                    "$mainMod, B, exec, ${browser}"
                    "$mainMod, Q, killactive"
                    "$SUPER_SHIFT, Q, forcekillactive"
                    "$SUPER_SHIFT, BACKSPACE, exit"
                    "$mainMod, V, togglefloating"
                    "$mainMod, F, fullscreen, 1" # Maximize
                    "$SUPER_SHIFT, F, fullscreen"
                    "$mainMod, H, movefocus, l"
                    "$mainMod, J, movefocus, d"
                    "$mainMod, K, movefocus, u"
                    "$mainMod, L, movefocus, r"

                    # Hyprpicker
                    "$SUPER_SHIFT, X, exec, ${disable_shader} hyprpicker --autocopy --lowercase-hex; ${enable_shader}"

                    # Screenshots
                    "$mainMod, P, exec, hyprshot -m window"
                    "$SUPER_SHIFT, P, exec, hyprshot -m region"
                    "$SUPER_CTRL, P, exec, hyprshot -m output -m active"

                    # Switch keyboard layouts
                    "$mainMod, Tab, exec, hyprctl switchxkblayout current next"

                    "$SUPER_SHIFT, H, resizeactive, -$rotate_val 0"
                    "$SUPER_SHIFT, J, resizeactive, 0 $rotate_val"
                    "$SUPER_SHIFT, K, resizeactive, 0 -$rotate_val"
                    "$SUPER_SHIFT, L, resizeactive, $rotate_val 0"
                    "$mainMod, 1, workspace, 1"
                    "$mainMod, 2, workspace, 2"
                    "$mainMod, 3, workspace, 3"
                    "$mainMod, 4, workspace, 4"
                    "$mainMod, 5, workspace, 5"
                    "$mainMod, 6, workspace, 6"
                    "$mainMod, 7, workspace, 7"
                    "$mainMod, 8, workspace, 8"
                    "$mainMod, 9, workspace, 9"
                    "$mainMod, 0, workspace, 10"
                    "$mainMod SHIFT, 1, movetoworkspace, 1"
                    "$mainMod SHIFT, 2, movetoworkspace, 2"
                    "$mainMod SHIFT, 3, movetoworkspace, 3"
                    "$mainMod SHIFT, 4, movetoworkspace, 4"
                    "$mainMod SHIFT, 5, movetoworkspace, 5"
                    "$mainMod SHIFT, 6, movetoworkspace, 6"
                    "$mainMod SHIFT, 7, movetoworkspace, 7"
                    "$mainMod SHIFT, 8, movetoworkspace, 8"
                    "$mainMod SHIFT, 9, movetoworkspace, 9"
                    "$mainMod SHIFT, 0, movetoworkspace, 10"
                ] ++ lib.optional vicinae.enable "$mainMod, SPACE, exec, vicinae toggle";

                bindm = [
                    "$mainMod, mouse:272, movewindow"
                    "$mainMod, mouse:273, resizewindow"
                ];

                decoration = {
                    screen_shader = "~/${shader_path}";
                };
            }

            # Add Nvidia config if necessary
            (lib.mkIf cfg.nvidia {
                env = [
                    "LIBVA_DRIVER_NAME, nvidia"
                    "__GLX_VENDOR_LIBRARY_NAME, nvidia"
                    "NVD_BACKEND, direct"
                    # Electron
                    "ELECTRON_OZONE_PLATFORM_HINT,auto"
                    "NIXOS_OZONE_WL=1"
                ];

                cursor = {
                    no_hardware_cursors = true;
                };

                misc = {
                    vrr = 1;
                };
            })

            (lib.mkIf laptop {
                bindel = [
                    ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
                    ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
                ];
                bindl = [
                    ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
                    ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

                    ", pause, exec, playerctl play-pause"
                ];
                bind = [
                    ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
                    ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
                ];
            })

            # Add extra config
            cfg.config
            themes.borders
        ];

        home.sessionVariables = {
            HYPRSHOT_DIR = "Pictures/screenshots";
        };

        home.file.".config/hypr/hyprlock.conf".text = ''
general {
    hide_cursor = true
}

background {
    path = screenshot
    blur_passes = 3
}

input-field {
    size = 20%, 5%
    outline_thickness = 1
    rounding = 15
    inner_color = 0xff${config.lib.stylix.colors.base00}
    outer_color = 0xff454545
    font_color = 0xff${config.lib.stylix.colors.base05}
    placeholder_text =
    fade_timeout = 0
}

        '';

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
