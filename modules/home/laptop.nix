{ ... }:

{
  # Lock/turn off the screen after 5 minutes idle. Desktops (ac-main-pc)
  # don't import this and are left unmanaged, i.e. never lock on idle.
  home.file.".config/cosmic/com.system76.CosmicIdle/v1/screen_off_time".text =
    "Some(300000)";
}
