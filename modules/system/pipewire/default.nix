{
    config,
    lib,
    ...
}:
let
    cfg    = config.systemSettings.pipewire;
    laptop = config.systemSettings.laptop;
in
{
    options = {
        systemSettings.pipewire.enable = lib.mkEnableOption "Enable Pipewire";
    };

    config = lib.mkIf cfg.enable {
        services.pipewire = {
            enable = true;
            pulse.enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;

            wireplumber.extraConfig = if !laptop then {
                    "51-prefer-headset" = {
                        "monitor.alsa.rules" = [
                            {
                                matches = [
                                    {
                                        "node.name" = "~alsa_output.usb-Logitech_G733.*";
                                    }
                                ];
                                actions = {
                                    "update-props" = {
                                        "priority.driver" = 2000;
                                        "priority.session" = 2000;
                                    };
                                };
                            }
                        ];
                    };
                } else {};

            extraConfig.pipewire."10-eq" = {
                "context.modules" = [
                    {
                        name = "libpipewire-module-filter-chain";
                        args = {
                            "node.description" = "NJ Sink";
                            "media.name" = "NJ Sink";
                            "filter.graph" = {
                                nodes = [
                                    {
                                        type = "builtin";
                                        name = "eq_band_32hz";
                                        label = "bq_peaking";
                                        control = {
                                            "Freq" = 32.0;
                                            "Q" = 4.36;
                                            "Gain" = 8.0;
                                        };
                                    }
                                    {
                                        type = "builtin";
                                        name = "eq_band_64hz";
                                        label = "bq_peaking";
                                        control = {
                                            "Freq" = 64.0;
                                            "Q" = 4.36;
                                            "Gain" = 7.0;
                                        };
                                    }
                                    {
                                        type = "builtin";
                                        name = "eq_band_125hz";
                                        label = "bq_peaking";
                                        control = {
                                            "Freq" = 125.0;
                                            "Q" = 4.36;
                                            "Gain" = 4.0;
                                        };
                                    }
                                    {
                                        type = "builtin";
                                        name = "eq_band_250hz";
                                        label = "bq_peaking";
                                        control = {
                                            "Freq" = 250.0;
                                            "Q" = 4.36;
                                            "Gain" = -4.0;
                                        };
                                    }
                                    {
                                        type = "builtin";
                                        name = "eq_band_500hz";
                                        label = "bq_peaking";
                                        control = {
                                            "Freq" = 500.0;
                                            "Q" = 4.36;
                                            "Gain" = -2.0;
                                        };
                                    }
                                    {
                                        type = "builtin";
                                        name = "eq_band_2khz";
                                        label = "bq_peaking";
                                        control = {
                                            "Freq" = 2000.0;
                                            "Q" = 4.36;
                                            "Gain" = 6.0;
                                        };
                                    }
                                    {
                                        type = "builtin";
                                        name = "eq_band_4khz";
                                        label = "bq_peaking";
                                        control = {
                                            "Freq" = 4000.0;
                                            "Q" = 4.36;
                                            "Gain" = 7.0;
                                        };
                                    }
                                    {
                                        type = "builtin";
                                        name = "eq_band_8khz";
                                        label = "bq_peaking";
                                        control = {
                                            "Freq" = 8000.0;
                                            "Q" = 4.36;
                                            "Gain" = 9.0;
                                        };
                                    }
                                    {
                                        type = "builtin";
                                        name = "eq_band_16khz";
                                        label = "bq_peaking";
                                        control = {
                                            "Freq" = 16000.0;
                                            "Q" = 4.36;
                                            "Gain" = 9.0;
                                        };
                                    }
                                ];

                                links = [
                                    { output = "eq_band_32hz:Out"; input = "eq_band_64hz:In"; }
                                    { output = "eq_band_64hz:Out"; input = "eq_band_125hz:In"; }
                                    { output = "eq_band_125hz:Out"; input = "eq_band_250hz:In"; }
                                    { output = "eq_band_250hz:Out"; input = "eq_band_500hz:In"; }
                                    { output = "eq_band_500hz:Out"; input = "eq_band_2khz:In"; }
                                    { output = "eq_band_2khz:Out"; input = "eq_band_4khz:In"; }
                                    { output = "eq_band_4khz:Out"; input = "eq_band_8khz:In"; }
                                    { output = "eq_band_8khz:Out"; input = "eq_band_16khz:In"; }
                                ];
                            };

                            "audio.channels" = 2;
                            "audio.position" = [ "FL" "FR" ];

                            "capture.props" = {
                                "node.name" = "effect_input.eq";
                                "media.class" = "Audio/Sink";
                            };

                            "playback.props" = {
                                "node.name" = "effect_output.eq";
                                "node.passive" = false;
                                "target.object" = "default";
                            };
                        };
                    }
                ];
            };
        };
    };
}
