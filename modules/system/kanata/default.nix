{
    config,
    lib,
    pkgs,
    ...
}:
let
    cfg    = config.systemSettings.kanata;
    laptop = config.systemSettings.laptop;
in
{
    options = {
        systemSettings.kanata.enable = lib.mkEnableOption "Enables Kanata";
        systemSettings.laptop        = lib.mkEnableOption "Enable Laptop Settings";
    };

    config = lib.mkIf cfg.enable {
        services.kanata.enable = true;
        services.kanata.keyboards = if !laptop then {
            default = {
                devices = [ "/dev/input/by-id/usb-OBINS_OBINS_AnnePro2_0100050595DF067602150B1C6309AFBD-event-kbd" ];
                config = ''
                    (defsrc
                        esc   1    2    3    4    5    6    7    8    9    0    -    =   bspc
                        tab   q    w    e    r    t    y    u    i    o    p    [    ]   \
                        lctl  a    s    d    f    g    h    j    k    l    ;    '    ret
                        lsft  z    x    c    v    b    n    m    ,    .    /    rsft
                              lmet lalt           spc            ralt left down right
                    )

                    (defalias
                        esctrl (tap-hold-press 150 150 esc lctrl)
                    )

                    (deflayer qwerty
                        esc      1    2    3    4    5    6    7    8    9    0    -    =   bspc
                        tab      q    w    e    r    t    y    u    i    o    p    [    ]   \
                        @esctrl  a    s    d    f    g    h    j    k    l    ;    '    ret
                        lsft     z    x    c    v    b    n    m    ,    .    /    rsft
                                 lmet lalt           spc            ralt left down right
                    )
                '';
            };
        } else {
            default = {
                config = ''
                    (defsrc
                esc    f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
                grv    1    2    3    4    5    6    7    8    9    0    -    =   bspc
                tab    q    w    e    r    t    y    u    i    o    p    [    ]   \
                caps   a    s    d    f    g    h    j    k    l    ;    '    ret
                lsft < z    x    c    v    b    n    m    ,    .    /    rsft      up
                lctl   lmet lalt           spc            ralt ro          left down rght
            )

            (defalias
                esctrl (tap-hold-press 150 150 esc lctrl)
            )

            (deflayer qwerty
              esc        f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
              \          1    2    3    4    5    6    7    8    9    0    -    =   bspc
              tab        q    w    e    r    t    y    u    i    o    p    [    ]   grv
              @esctrl    a    s    d    f    g    h    j    k    l    ;    '    ret
              lsft   esc z    x    c    v    b    n    m    ,    .    /    rsft          up
              lctl       lmet lalt           spc            ralt rmet               left down rght
            )
                '';
            };
        };
    };
}
