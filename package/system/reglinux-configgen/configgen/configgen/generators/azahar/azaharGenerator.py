from generators.Generator import Generator
from Command import Command
import os
import subprocess
import configparser
from systemFiles import CONF
from os import environ

from utils.logger import get_logger
eslog = get_logger(__name__)

class AzaharGenerator(Generator):
    # this emulator/core requires X server to run
    def requiresX11(self):
        return True

    # Main entry of the module
    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        AzaharGenerator.writeCITRAConfig(CONF + "/citra-emu/qt-config.ini", system, playersControllers)

        commandArray = ['/usr/bin/azahar', rom]
        return Command(array=commandArray)

    # Show mouse on screen
    def getMouseMode(self, config, rom):
        if "azahar_screen_layout" in config and config["azahar_screen_layout"] == "1-false":
            return False
        else:
            return True

    @staticmethod
    def writeCITRAConfig(citraConfigFile, system, playersControllers):
        # Pads
        citraButtons = {
            "button_a":      "a",
            "button_b":      "b",
            "button_x":      "x",
            "button_y":      "y",
            "button_up":     "up",
            "button_down":   "down",
            "button_left":   "left",
            "button_right":  "right",
            "button_l":      "pageup",
            "button_r":      "pagedown",
            "button_start":  "start",
            "button_select": "select",
            "button_zl":     "l2",
            "button_zr":     "r2",
            "button_home":   "hotkey"
        }

        citraAxis = {
            "circle_pad":    "joystick1",
            "c_stick":       "joystick2"
        }

        # ini file
        citraConfig = configparser.RawConfigParser(strict=False)
        citraConfig.optionxform=lambda optionstr: str(optionstr)             # Add Case Sensitive comportement
        if os.path.exists(citraConfigFile):
            citraConfig.read(citraConfigFile)

        ## [LAYOUT]
        if not citraConfig.has_section("Layout"):
            citraConfig.add_section("Layout")
        # Screen Layout
        citraConfig.set("Layout", "custom_layout", "false")
        citraConfig.set("Layout", "custom_layout\\default", "true")
        if system.isOptSet('azahar_screen_layout'):
            tab = system.config["azahar_screen_layout"].split('-')
            citraConfig.set("Layout", "swap_screen",   tab[1])
            citraConfig.set("Layout", "layout_option", tab[0])
        else:
            citraConfig.set("Layout", "swap_screen", "false")
            citraConfig.set("Layout", "layout_option", "0")
        citraConfig.set("Layout", "swap_screen\\default", "false")
        citraConfig.set("Layout", "layout_option\\default", "false")

        ## [SYSTEM]
        if not citraConfig.has_section("System"):
            citraConfig.add_section("System")
        # New 3DS Version
        if system.isOptSet('azahar_is_new_3ds') and system.config["azahar_is_new_3ds"] == '1':
            citraConfig.set("System", "is_new_3ds", "true")
        else:
            citraConfig.set("System", "is_new_3ds", "false")
        citraConfig.set("System", "is_new_3ds\\default", "false")
        # Language
        citraConfig.set("System", "region_value", str(getCitraLangFromEnvironment()))
        citraConfig.set("System", "region_value\\default", "false")

        ## [UI]
        if not citraConfig.has_section("UI"):
            citraConfig.add_section("UI")
        # Start Fullscreen
        citraConfig.set("UI", "fullscreen", "true")
        citraConfig.set("UI", "fullscreen\\default", "false")

        # Batocera - Defaults
        citraConfig.set("UI", "displayTitleBars", "false")
        citraConfig.set("UI", "displaytitlebars", "false") # Emulator Bug
        citraConfig.set("UI", "displayTitleBars\\default", "false")
        citraConfig.set("UI", "firstStart", "false")
        citraConfig.set("UI", "firstStart\\default", "false")
        citraConfig.set("UI", "hideInactiveMouse", "true")
        citraConfig.set("UI", "hideInactiveMouse\\default", "false")
        citraConfig.set("UI", "enable_discord_presence", "false")
        citraConfig.set("UI", "enable_discord_presence\\default", "false")

        # Remove pop-up prompt on start
        citraConfig.set("UI", "calloutFlags", "1")
        citraConfig.set("UI", "calloutFlags\\default", "false")
        # Close without confirmation
        citraConfig.set("UI", "confirmClose", "false")
        citraConfig.set("UI", "confirmclose", "false") # Emulator Bug
        citraConfig.set("UI", "confirmClose\\default", "false")

        # screenshots
        citraConfig.set("UI", "Paths\\screenshotPath", "/userdata/screenshots")
        citraConfig.set("UI", "Paths\\screenshotPath\\default", "false")

        # don't check updates
        citraConfig.set("UI", "Updater\\check_for_update_on_start", "false")
        citraConfig.set("UI", "Updater\\check_for_update_on_start\\default", "false")

        ## [RENDERER]
        if not citraConfig.has_section("Renderer"):
            citraConfig.add_section("Renderer")
        # Force Hardware Rrendering / Shader or nothing works fine
        citraConfig.set("Renderer", "use_hw_renderer", "true")
        citraConfig.set("Renderer", "use_hw_shader",   "true")
        citraConfig.set("Renderer", "use_shader_jit",  "true")
        # Software, OpenGL (default) or Vulkan
        if system.isOptSet('azahar_graphics_api'):
            citraConfig.set("Renderer", "graphics_api", system.config["azahar_graphics_api"])
        else:
            citraConfig.set("Renderer", "graphics_api", "1")
        # Set Vulkan as necessary
        if system.isOptSet("azahar_graphics_api") and system.config["azahar_graphics_api"] == "2":
            try:
                have_vulkan = subprocess.check_output(["/usr/bin/system-vulkan", "hasVulkan"], text=True).strip()
                if have_vulkan == "true":
                    eslog.debug("Vulkan driver is available on the system.")
                    try:
                        have_discrete = subprocess.check_output(["/usr/bin/system-vulkan", "hasDiscrete"], text=True).strip()
                        if have_discrete == "true":
                            eslog.debug("A discrete GPU is available on the system. We will use that for performance")
                            try:
                                discrete_index = subprocess.check_output(["/usr/bin/system-vulkan", "discreteIndex"], text=True).strip()
                                if discrete_index != "":
                                    eslog.debug("Using Discrete GPU Index: {} for Citra".format(discrete_index))
                                    citraConfig.set("Renderer", "physical_device", discrete_index)
                                else:
                                    eslog.debug("Couldn't get discrete GPU index")
                            except subprocess.CalledProcessError:
                                eslog.debug("Error getting discrete GPU index")
                        else:
                            eslog.debug("Discrete GPU is not available on the system. Trying integrated.")
                            have_integrated = subprocess.check_output(["/usr/bin/system-vulkan", "hasIntegrated"], text=True).strip()
                            if have_integrated == "true":
                                eslog.debug("Using integrated GPU to provide Vulkan. Beware of performance")
                                try:
                                    integrated_index = subprocess.check_output(["/usr/bin/system-vulkan", "integratedIndex"], text=True).strip()
                                    if integrated_index != "":
                                        eslog.debug("Using Integrated GPU Index: {} for Citra".format(integrated_index))
                                        citraConfig.set("Renderer", "physical_device", integrated_index)
                                    else:
                                        eslog.debug("Couldn't get integrated GPU index")
                                except subprocess.CalledProcessError:
                                    eslog.debug("Error getting integrated GPU index")
                            else:
                                eslog.debug("Integrated GPU is not available on the system. Cannot enable Vulkan.")
                    except subprocess.CalledProcessError:
                        eslog.debug("Error checking for discrete GPU.")
            except subprocess.CalledProcessError:
                eslog.debug("Error executing system-vulkan script.")
        # Use VSYNC
        if system.isOptSet('azahar_use_vsync_new') and system.config["azahar_use_vsync_new"] == '0':
            citraConfig.set("Renderer", "use_vsync_new", "false")
        else:
            citraConfig.set("Renderer", "use_vsync_new", "true")
        citraConfig.set("Renderer", "use_vsync_new\\default", "true")
        # Resolution Factor
        if system.isOptSet('azahar_resolution_factor'):
            citraConfig.set("Renderer", "resolution_factor", system.config["azahar_resolution_factor"])
        else:
            citraConfig.set("Renderer", "resolution_factor", "1")
        citraConfig.set("Renderer", "resolution_factor\\default", "false")
        # Async Shader Compilation
        if system.isOptSet('azahar_async_shader_compilation') and system.config["azahar_async_shader_compilation"] == '1':
            citraConfig.set("Renderer", "async_shader_compilation", "true")
        else:
            citraConfig.set("Renderer", "async_shader_compilation", "false")
        citraConfig.set("Renderer", "async_shader_compilation\\default", "false")
        # Use Frame Limit
        if system.isOptSet('azahar_use_frame_limit') and system.config["azahar_use_frame_limit"] == '0':
            citraConfig.set("Renderer", "use_frame_limit", "false")
        else:
            citraConfig.set("Renderer", "use_frame_limit", "true")

        ## [WEB SERVICE]
        if not citraConfig.has_section("WebService"):
            citraConfig.add_section("WebService")
        citraConfig.set("WebService", "enable_telemetry",  "false")

        ## [UTILITY]
        if not citraConfig.has_section("Utility"):
            citraConfig.add_section("Utility")
        # Disk Shader Cache
        if system.isOptSet('azahar_use_disk_shader_cache') and system.config["azahar_use_disk_shader_cache"] == '1':
            citraConfig.set("Utility", "use_disk_shader_cache", "true")
        else:
            citraConfig.set("Utility", "use_disk_shader_cache", "false")
        citraConfig.set("Utility", "use_disk_shader_cache\\default", "false")
        # Custom Textures
        if system.isOptSet('azahar_custom_textures') and system.config["azahar_custom_textures"] != '0':
            tab = system.config["azahar_custom_textures"].split('-')
            citraConfig.set("Utility", "custom_textures",  "true")
            if tab[1] == 'normal':
                citraConfig.set("Utility", "async_custom_loading", "true")
                citraConfig.set("Utility", "preload_textures", "false")
            else:
                citraConfig.set("Utility", "async_custom_loading", "false")
                citraConfig.set("Utility", "preload_textures", "true")
        else:
            citraConfig.set("Utility", "custom_textures",  "false")
            citraConfig.set("Utility", "preload_textures", "false")
        citraConfig.set("Utility", "async_custom_loading\\default", "true")
        citraConfig.set("Utility", "custom_textures\\default", "false")
        citraConfig.set("Utility", "preload_textures\\default", "false")

        ## [CONTROLS]
        if not citraConfig.has_section("Controls"):
            citraConfig.add_section("Controls")

        # Options required to load the functions when the configuration file is created
        if not citraConfig.has_option("Controls", "profiles\\size"):
            citraConfig.set("Controls", "profile", 0)
            citraConfig.set("Controls", "profile\\default", "true")
            citraConfig.set("Controls", "profiles\\1\\name", "default")
            citraConfig.set("Controls", "profiles\\1\\name\\default", "true")
            citraConfig.set("Controls", "profiles\\size", 1)

        for index in playersControllers :
            controller = playersControllers[index]
            # We only care about player 1
            if controller.player != "1":
                continue
            for x in citraButtons:
                citraConfig.set("Controls", "profiles\\1\\" + x, f'"{CitraGenerator.setButton(citraButtons[x], controller.guid, controller.inputs)}"')
            for x in citraAxis:
                citraConfig.set("Controls", "profiles\\1\\" + x, f'"{CitraGenerator.setAxis(citraAxis[x], controller.guid, controller.inputs)}"')
            break

        ## Update the configuration file
        if not os.path.exists(os.path.dirname(citraConfigFile)):
            os.makedirs(os.path.dirname(citraConfigFile))
        with open(citraConfigFile, 'w') as configfile:
            citraConfig.write(configfile)

    @staticmethod
    def setButton(key, padGuid, padInputs):
        # It would be better to pass the joystick num instead of the guid because 2 joysticks may have the same guid
        if key in padInputs:
            input = padInputs[key]

            if input.type == "button":
                return ("button:{},guid:{},engine:sdl").format(input.id, padGuid)
            elif input.type == "hat":
                return ("engine:sdl,guid:{},hat:{},direction:{}").format(padGuid, input.id, CitraGenerator.hatdirectionvalue(input.value))
            elif input.type == "axis":
                # Untested, need to configure an axis as button / triggers buttons to be tested too
                return ("engine:sdl,guid:{},axis:{},direction:{},threshold:{}").format(padGuid, input.id, "+", 0.5)

    @staticmethod
    def setAxis(key, padGuid, padInputs):
        inputx = None
        inputy = None

        if key == "joystick1" and "joystick1left" in padInputs:
            inputx = padInputs["joystick1left"]
        elif key == "joystick2" and "joystick2left" in padInputs:
            inputx = padInputs["joystick2left"]

        if key == "joystick1" and "joystick1up" in padInputs:
            inputy = padInputs["joystick1up"]
        elif key == "joystick2" and "joystick2up" in padInputs:
            inputy = padInputs["joystick2up"]

        if inputx is None or inputy is None:
            return "";

        return ("axis_x:{},guid:{},axis_y:{},engine:sdl").format(inputx.id, padGuid, inputy.id)

    @staticmethod
    def hatdirectionvalue(value):
        if int(value) == 1:
            return "up"
        if int(value) == 4:
            return "down"
        if int(value) == 2:
            return "right"
        if int(value) == 8:
            return "left"
        return "unknown"

# Language auto setting
def getCitraLangFromEnvironment():
    region = { "AUTO": -1, "JPN": 0, "USA": 1, "EUR": 2, "AUS": 3, "CHN": 4, "KOR": 5, "TWN": 6 }
    availableLanguages = {
        "ja_JP": "JPN",
        "en_US": "USA",
        "de_DE": "EUR",
        "es_ES": "EUR",
        "fr_FR": "EUR",
        "it_IT": "EUR",
        "hu_HU": "EUR",
        "pt_PT": "EUR",
        "ru_RU": "EUR",
        "en_AU": "AUS",
        "zh_CN": "CHN",
        "ko_KR": "KOR",
        "zh_TW": "TWN"
    }
    lang = environ['LANG'][:5]
    if lang in availableLanguages:
        return region[availableLanguages[lang]]
    else:
        return region["AUTO"]
