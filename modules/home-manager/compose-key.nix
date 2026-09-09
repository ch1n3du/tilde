{ ... }:

{
  # GNOME/Wayland builds its keymap from org.gnome.desktop.input-sources rather
  # than localed, so services.xserver.xkb.options does not reach native Wayland
  # apps on its own.
  dconf.settings."org/gnome/desktop/input-sources".xkb-options = [
    "terminate:ctrl_alt_bksp"
    "compose:ralt"
  ];
}
