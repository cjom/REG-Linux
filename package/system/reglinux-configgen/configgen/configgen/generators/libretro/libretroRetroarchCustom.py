import os
from settings.unixSettings import UnixSettings
from . import libretroConfig

def generateRetroarchCustom():
    # retroarchcustom.cfg
    if not os.path.exists(os.path.dirname(libretroConfig.retroarchCustom)):
        os.makedirs(os.path.dirname(libretroConfig.retroarchCustom))

    try:
        retroarchSettings = UnixSettings(libretroConfig.retroarchCustom, separator=' ')
    except UnicodeError:
        os.remove(libretroConfig.retroarchCustom)
        retroarchSettings = UnixSettings(libretroConfig.retroarchCustom, separator=' ')

    # Use Interface
    retroarchSettings.save('menu_driver',                       '"ozone"')
    retroarchSettings.save('content_show_favorites',            '"false"')
    retroarchSettings.save('content_show_images',               '"false"')
    retroarchSettings.save('content_show_music',                '"false"')
    retroarchSettings.save('content_show_video',                '"false"')
    retroarchSettings.save('content_show_history',              '"false"')
    retroarchSettings.save('content_show_playlists',            '"false"')
    retroarchSettings.save('content_show_add',                  '"false"')
    retroarchSettings.save('menu_show_load_core',               '"false"')
    retroarchSettings.save('menu_show_load_content',            '"false"')
    retroarchSettings.save('menu_show_online_updater',          '"false"')
    retroarchSettings.save('menu_show_core_updater',            '"false"')

    # Input (SDL2 based)
    retroarchSettings.save('input_autodetect_enable',           '"true"')
    retroarchSettings.save('input_remap_binds_enable',          '"true"')
    retroarchSettings.save('input_joypad_driver',               '"sdl2"')
    retroarchSettings.save('input_enable_hotkey_btn',           '"5"')
    retroarchSettings.save('input_reset_btn',                   '"0"')
    retroarchSettings.save('input_menu_toggle_btn',             '"3"')
    retroarchSettings.save('input_exit_emulator_btn',           '"6"')
    retroarchSettings.save('input_load_state_btn',              '"10"')
    retroarchSettings.save('input_save_state_btn',              '"9"')
    retroarchSettings.save('input_state_slot_increase_btn',     '"13"')
    retroarchSettings.save('input_state_slot_decrease_btn',     '"14"')
    retroarchSettings.save('input_player1_analog_dpad_mode',    '"1"')
    retroarchSettings.save('input_player2_analog_dpad_mode',    '"1"')
    retroarchSettings.save('input_player3_analog_dpad_mode',    '"1"')
    retroarchSettings.save('input_player4_analog_dpad_mode',    '"1"')
    retroarchSettings.save('input_player5_analog_dpad_mode',    '"1"')
    retroarchSettings.save('input_player6_analog_dpad_mode',    '"1"')
    retroarchSettings.save('input_player7_analog_dpad_mode',    '"1"')
    retroarchSettings.save('input_player8_analog_dpad_mode',    '"1"')
    retroarchSettings.save('input_enable_hotkey',               '"shift"')
    retroarchSettings.save('input_menu_toggle',                 '"f1"')
    retroarchSettings.save('input_exit_emulator',               '"escape"')

    # Video
    retroarchSettings.save('video_aspect_ratio_auto',           '"false"')
    retroarchSettings.save('video_gpu_screenshot',              '"true"')
    retroarchSettings.save('video_shader_enable',               '"false"')
    retroarchSettings.save('aspect_ratio_index',                '"22"')

    # Audio
    retroarchSettings.save('audio_volume',                       '"2.0"')

    # Settings
    retroarchSettings.save('global_core_options',               '"true"')
    retroarchSettings.save('config_save_on_exit',               '"false"')
    retroarchSettings.save('savestate_auto_save',               '"false"')
    retroarchSettings.save('savestate_auto_load',               '"false"')
    retroarchSettings.save('menu_swap_ok_cancel_buttons',       '"true"')

    # Accentuation
    retroarchSettings.save('rgui_extended_ascii',               '"true"')

    # Hide the welcome message in Retroarch
    retroarchSettings.save('rgui_show_start_screen',            '"false"')

    # Enable usage of OSD messages (Text messages not in badge)
    retroarchSettings.save('video_font_enable',                 '"true"')

    # Take a screenshot of the savestate
    retroarchSettings.save('savestate_thumbnail_enable',        '"true"')

    # Allow any RetroPad to control the menu (Only the player 1)
    retroarchSettings.save('all_users_control_menu',            '"false"')

    # Show badges in Retroarch cheevos list
    retroarchSettings.save('cheevos_badges_enable',             '"true"')

    # Disable builtin image viewer (done in ES, and prevents from loading pico-8 .png carts)
    retroarchSettings.save('builtin_imageviewer_enable',        '"false"')

    # Set fps counter interval (in frames)
    retroarchSettings.save('fps_update_interval',               '"30"')

    retroarchSettings.write()

def generateRetroarchCustomPathes(retroarchSettings):
    # Path Retroarch
    retroarchSettings.save('core_options_path',             '"/userdata/system/configs/retroarch/cores/retroarch-core-options.cfg"')
    retroarchSettings.save('assets_directory',              '"/usr/share/libretro/assets"')
    retroarchSettings.save('screenshot_directory',          '"/userdata/screenshots/"')
    retroarchSettings.save('recording_output_directory',    '"/userdata/screenshots/"')
    retroarchSettings.save('savestate_directory',           '"/userdata/saves/"')
    retroarchSettings.save('savefile_directory',            '"/userdata/saves/"')
    retroarchSettings.save('extraction_directory',          '"/userdata/extractions/"')
    retroarchSettings.save('cheat_database_path',           '"/userdata/cheats/cht/"')
    retroarchSettings.save('cheat_settings_path',           '"/userdata/cheats/saves/"')
    retroarchSettings.save('system_directory',              '"/userdata/bios/"')
    retroarchSettings.save('joypad_autoconfig_dir',         '"/userdata/system/configs/retroarch/autoconfig/"')
    retroarchSettings.save('video_shader_dir',              '"/usr/share/reglinux/shaders/"')
    retroarchSettings.save('video_filter_dir',              '"/usr/share/video_filters"')
    retroarchSettings.save('audio_filter_dir',              '"/usr/share/audio_filters"')
