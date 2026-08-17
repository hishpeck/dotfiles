{ lib, ... }:

let
  wallpaper = ../../../wallpapers/takashi-miyazaki.jpg;

  # Panel applet lists
  panelLeft = ''
    Some(([
        "com.github.nwxnw.cosmic-ext-whether",
        "com.system76.CosmicPanelWorkspacesButton",
        "com.system76.CosmicPanelAppButton",
        "com.system76.CosmicAppletWorkspaces",
    ], [
        "com.system76.CosmicAppletInputSources",
        "io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager",
        "com.system76.CosmicAppletStatusArea",
        "com.system76.CosmicAppletTiling",
        "com.github.MusicPlayer",
        "com.system76.CosmicAppletAudio",
        "com.system76.CosmicAppletBluetooth",
        "com.system76.CosmicAppletNetwork",
        "com.system76.CosmicAppletBattery",
        "com.system76.CosmicAppletNotifications",
        "com.system76.CosmicAppletPower",
    ]))'';

  panelCenter = ''
    Some([
        "io.github.cosmic_utils.minimon-applet",
        "com.system76.CosmicAppletTime",
        "dev.DBrox.CosmicPrivacyIndicator",
    ])'';

  dockCenter = ''
    Some([
        "com.system76.CosmicPanelLauncherButton",
        "com.system76.CosmicPanelWorkspacesButton",
        "com.system76.CosmicPanelAppButton",
        "com.system76.CosmicAppList",
        "com.system76.CosmicAppletMinimize",
    ])'';

in
{
  home.file = lib.mapAttrs (name: value: value // { force = true; }) {
    # ── Wallpaper ───────────────────────────────────────────────────────────────
    ".config/cosmic/com.system76.CosmicBackground/v1/all".text = ''
      (
          output: "all",
          source: Path("${wallpaper}"),
          filter_by_theme: true,
          rotation_frequency: 300,
          filter_method: Lanczos,
          scaling_mode: Zoom,
          sampling_method: Alphanumeric,
      )'';
    ".config/cosmic/com.system76.CosmicBackground/v1/same-on-all".text = "true";
    ".config/cosmic/com.system76.CosmicSettings.Wallpaper/v1/custom-images".text = ''
      ["${wallpaper}"]'';

    # ── Panel entries list ──────────────────────────────────────────────────────
    ".config/cosmic/com.system76.CosmicPanel/v1/entries".text = ''
      [
          "Panel",
          "Dock",
      ]'';

    # ── Panel ───────────────────────────────────────────────────────────────────
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/name".text = ''"Panel"'';
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/anchor".text = "Top";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/size".text = "XS";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/layer".text = "Top";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/output".text = "All";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/background".text = "ThemeDefault";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/opacity".text = "0.8";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/margin".text = "4";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/padding".text = "0";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/spacing".text = "0";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/border_radius".text = "160";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/padding_overlap".text = "0.5";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/anchor_gap".text = "true";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/exclusive_zone".text = "true";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/expand_to_edges".text = "true";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/keyboard_interactivity".text = "OnDemand";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/autohide".text = "None";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/autohover_delay_ms".text = "Some(500)";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/size_center".text = "None";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/size_wings".text = "None";
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/plugins_center".text = panelCenter;
    ".config/cosmic/com.system76.CosmicPanel.Panel/v1/plugins_wings".text = panelLeft;

    # ── Dock ────────────────────────────────────────────────────────────────────
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/name".text = ''"Dock"'';
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/anchor".text = "Bottom";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/size".text = "S";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/layer".text = "Top";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/output".text = "All";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/background".text = "ThemeDefault";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/opacity".text = "1.0";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/margin".text = "4";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/padding".text = "4";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/spacing".text = "0";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/border_radius".text = "160";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/anchor_gap".text = "true";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/exclusive_zone".text = "false";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/expand_to_edges".text = "false";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/keyboard_interactivity".text = "OnDemand";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/autohide".text = ''
      Some((
          wait_time: 1000,
          transition_time: 200,
          handle_size: 4,
          unhide_delay: 200,
      ))'';
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/autohover_delay_ms".text = "Some(500)";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/size_center".text = "None";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/size_wings".text = "None";
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/plugins_center".text = dockCenter;
    ".config/cosmic/com.system76.CosmicPanel.Dock/v1/plugins_wings".text = "Some(([], []))";

    # ── Keybindings ─────────────────────────────────────────────────────────────
    ".config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom".text = ''
      {
          (
              modifiers: [
                  Ctrl,
                  Alt,
              ],
              key: "Left",
          ): Disable,
          (
              modifiers: [
                  Super,
              ],
              key: "space",
          ): Spawn("walker"),
          (
              modifiers: [
                  Super,
              ],
              key: "v",
          ): Spawn("walker -m clipboard"),
          (
              modifiers: [
                  Super,
              ],
              key: "Return",
          ): Disable,
          (
              modifiers: [
                  Super,
              ],
              key: "Tab",
          ): System(WorkspaceOverview),
          (
              modifiers: [
                  Super,
              ],
              key: "n",
          ): Minimize,
          (
              modifiers: [],
              key: "Print",
          ): System(Screenshot),
          (
              modifiers: [
                  Super,
                  Shift,
              ],
              key: "s",
          ): System(Screenshot),
          (
              modifiers: [
                  Super,
                  Ctrl,
              ],
              key: "Left",
          ): Disable,
      }'';
    ".config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions".text = ''
      {
          Terminal: "kitty",
      }'';

    # ── Window rules ────────────────────────────────────────────────────────────
    ".config/cosmic/com.system76.CosmicSettings.WindowRules/v1/tiling_exception_custom".text = ''
      [
          (
              appid: "google-chrome",
              title: "Picture in Picture",
              enabled: true,
          ),
          (
              appid: "google-chrome",
              title: "^Meet – [^-]*$",
              enabled: true,
          ),
      ]'';

    # ── Compositor ──────────────────────────────────────────────────────────────
    ".config/cosmic/com.system76.CosmicComp/v1/autotile".text = "true";
    ".config/cosmic/com.system76.CosmicComp/v1/autotile_behavior".text = "PerWorkspace";
    ".config/cosmic/com.system76.CosmicComp/v1/descale_xwayland".text = "false";
    ".config/cosmic/com.system76.CosmicComp/v1/xkb_config".text = ''
      (
          rules: "",
          model: "",
          layout: "pl",
          variant: "",
          options: None,
          repeat_delay: 600,
          repeat_rate: 25,
      )'';
    ".config/cosmic/com.system76.CosmicComp/v1/input_default".text = ''
      (
          state: Enabled,
          acceleration: Some((
              profile: Some(Flat),
              speed: -0.24430915004949794,
          )),
      )'';

    # ── Time applet ─────────────────────────────────────────────────────────────
    ".config/cosmic/com.system76.CosmicAppletTime/v1/military_time".text = "true";
    ".config/cosmic/com.system76.CosmicAppletTime/v1/first_day_of_week".text = "0";

    # ── Idle ────────────────────────────────────────────────────────────────────
    ".config/cosmic/com.system76.CosmicIdle/v1/screen_off_time".text = "None";
    ".config/cosmic/com.system76.CosmicIdle/v1/suspend_on_ac_time".text = "None";

    # ── Minimon applet ──────────────────────────────────────────────────────────
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/content_order".text = ''
      (
          order: [
              CpuUsage,
              CpuTemp,
              MemoryUsage,
              NetworkUsage,
              DiskUsage,
              GpuInfo,
          ],
      )'';
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/cpu".text = ''
      (
          chart_visible: true,
          value_visible: false,
          label_visible: false,
          icon_visible: true,
          chart: Line,
          colors: (
              ring: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                  graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              line: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 6, blue: 0, alpha: 85),
                  graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              heat: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                  graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              stackedbars: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 80, green: 80, blue: 255, alpha: 255),
                  graph2: (red: 255, green: 0, blue: 0, alpha: 255),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
          ),
          no_decimals: false,
          bar_width: 4,
          bar_spacing: 1,
      )'';
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/cputemp".text = ''
      (
          chart_visible: true,
          value_visible: false,
          label_visible: false,
          icon_visible: true,
          chart: Heat,
          colors: (
              ring: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                  graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              line: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 90, blue: 0, alpha: 85),
                  graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              heat: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                  graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              stackedbars: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                  graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
          ),
          unit: Celsius,
          min_temp: 20.0,
      )'';
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/disks1".text = ''
      (
          chart_visible: false,
          value_visible: false,
          label_visible: false,
          icon_visible: true,
          chart: Line,
          colors: (
              ring: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 102, blue: 0, alpha: 85),
                  graph2: (red: 255, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              line: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 102, blue: 0, alpha: 85),
                  graph2: (red: 255, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              heat: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 102, blue: 0, alpha: 85),
                  graph2: (red: 255, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              stackedbars: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 102, blue: 0, alpha: 85),
                  graph2: (red: 255, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
          ),
          variant: Combined,
      )'';
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/disks2".text = ''
      (
          chart_visible: false,
          value_visible: false,
          label_visible: false,
          icon_visible: true,
          chart: Line,
          colors: (
              ring: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 102, blue: 0, alpha: 85),
                  graph2: (red: 255, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              line: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 102, blue: 0, alpha: 85),
                  graph2: (red: 255, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              heat: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 102, blue: 0, alpha: 85),
                  graph2: (red: 255, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              stackedbars: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 102, blue: 0, alpha: 85),
                  graph2: (red: 255, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
          ),
          variant: Read,
      )'';
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/gpus".text = ''
      {
          "1714face7ad6366e6ee445aa74bc8cba9af94422fa2668f2f0b1b0024ca28af5": (
              usage: (
                  chart_visible: false,
                  value_visible: false,
                  label_visible: false,
                  icon_visible: true,
                  chart: Ring,
                  colors: (
                      ring: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 0, green: 255, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      line: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 0, green: 255, blue: 0, alpha: 85),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      heat: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      stackedbars: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                  ),
              ),
              vram: (
                  chart_visible: false,
                  value_visible: false,
                  label_visible: false,
                  icon_visible: true,
                  chart: Ring,
                  colors: (
                      ring: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 0, green: 255, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      line: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 0, green: 255, blue: 0, alpha: 85),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      heat: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      stackedbars: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                  ),
              ),
              temp: (
                  chart_visible: false,
                  value_visible: false,
                  label_visible: false,
                  icon_visible: true,
                  chart: Ring,
                  colors: (
                      ring: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      line: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 85),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      heat: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      stackedbars: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                  ),
                  unit: Celsius,
                  min_temp: 0.0,
              ),
              pause_on_battery: true,
              stack_values: true,
          ),
          "9e4cf2c4712472d92f1636f3820cadfa96acf9b9e2e8c1310165d00dcfc80961": (
              usage: (
                  chart_visible: false,
                  value_visible: false,
                  label_visible: false,
                  icon_visible: true,
                  chart: Ring,
                  colors: (
                      ring: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 0, green: 255, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      line: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 0, green: 255, blue: 0, alpha: 85),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      heat: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      stackedbars: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                  ),
              ),
              vram: (
                  chart_visible: false,
                  value_visible: false,
                  label_visible: false,
                  icon_visible: true,
                  chart: Ring,
                  colors: (
                      ring: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 0, green: 255, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      line: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 0, green: 255, blue: 0, alpha: 85),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      heat: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      stackedbars: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                  ),
              ),
              temp: (
                  chart_visible: false,
                  value_visible: false,
                  label_visible: false,
                  icon_visible: true,
                  chart: Ring,
                  colors: (
                      ring: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      line: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 85),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      heat: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                      stackedbars: (
                          background: (red: 43, green: 43, blue: 43, alpha: 255),
                          frame: (red: 255, green: 255, blue: 255, alpha: 255),
                          text: (red: 255, green: 255, blue: 255, alpha: 255),
                          graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                          graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                          graph3: (red: 255, green: 165, blue: 0, alpha: 255),
                      ),
                  ),
                  unit: Celsius,
                  min_temp: 0.0,
              ),
              pause_on_battery: true,
              stack_values: true,
          ),
      }'';
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/label_size_default".text = "11";
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/memory".text = ''
      (
          chart_visible: true,
          value_visible: false,
          label_visible: false,
          icon_visible: true,
          chart: Line,
          colors: (
              ring: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 29, green: 172, blue: 214, alpha: 255),
                  graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                  graph3: (red: 44, green: 87, blue: 101, alpha: 255),
              ),
              line: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 29, green: 172, blue: 214, alpha: 140),
                  graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                  graph3: (red: 44, green: 87, blue: 101, alpha: 140),
              ),
              heat: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                  graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              stackedbars: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 255, green: 6, blue: 0, alpha: 255),
                  graph2: (red: 85, green: 85, blue: 85, alpha: 255),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
          ),
          percentage: true,
          show_allocated: false,
          stack_values: false,
      )'';
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/monospace_labels".text = "true";
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/monospace_values".text = "false";
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/network1".text = ''
      (
          chart_visible: false,
          value_visible: false,
          label_visible: false,
          icon_visible: true,
          chart: Line,
          colors: (
              ring: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 47, green: 141, blue: 255, alpha: 85),
                  graph2: (red: 0, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              line: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 47, green: 141, blue: 255, alpha: 85),
                  graph2: (red: 0, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              heat: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 47, green: 141, blue: 255, alpha: 85),
                  graph2: (red: 0, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              stackedbars: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 47, green: 141, blue: 255, alpha: 85),
                  graph2: (red: 0, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
          ),
          adaptive: true,
          bandwidth: 62500000,
          unit: Some(0),
          variant: Combined,
          show_bytes: false,
      )'';
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/network2".text = ''
      (
          chart_visible: true,
          value_visible: false,
          label_visible: false,
          icon_visible: true,
          chart: Line,
          colors: (
              ring: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 47, green: 141, blue: 255, alpha: 85),
                  graph2: (red: 0, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              line: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 47, green: 141, blue: 255, alpha: 85),
                  graph2: (red: 0, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              heat: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 47, green: 141, blue: 255, alpha: 85),
                  graph2: (red: 0, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
              stackedbars: (
                  background: (red: 43, green: 43, blue: 43, alpha: 255),
                  frame: (red: 255, green: 255, blue: 255, alpha: 255),
                  text: (red: 255, green: 255, blue: 255, alpha: 255),
                  graph1: (red: 47, green: 141, blue: 255, alpha: 85),
                  graph2: (red: 0, green: 255, blue: 0, alpha: 85),
                  graph3: (red: 255, green: 165, blue: 0, alpha: 255),
              ),
          ),
          adaptive: true,
          bandwidth: 62500000,
          unit: Some(0),
          variant: Upload,
          show_bytes: false,
      )'';
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/panel_spacing".text = "4";
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/refresh_rate".text = "5000";
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/symbols".text = "true";
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/sysmon".text = "None";
    ".config/cosmic/io.github.cosmic_utils.minimon-applet-panel/v1/value_size_default".text = "11";

    # ── Whether (weather) applet ────────────────────────────────────────────────
    ".config/cosmic/com.github.nwxnw.cosmic-ext-whether/v4/use_fahrenheit".text = "false";
    ".config/cosmic/com.github.nwxnw.cosmic-ext-whether/v4/refresh_interval_minutes".text = "30";
    ".config/cosmic/com.github.nwxnw.cosmic-ext-whether/v4/active_location_index".text = "0";
    ".config/cosmic/com.github.nwxnw.cosmic-ext-whether/v4/locations".text = ''
      [
          (
              name: "Warszawa, województwo mazowieckie",
              lat: "52.2333742",
              lon: "21.0711489",
              cached_grid: None,
              source: OpenMeteo,
              country_code: Some("pl"),
          ),
      ]'';
  };
}
