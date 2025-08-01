from generators.Generator import Generator
from Command import Command
import os.path
from shutil import copyfile
from . import xemuConfig

class XemuGenerator(Generator):

    # Main entry of the module
    # Configure fba and return a command
    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        xemuConfig.writeIniFile(system, rom, playersControllers, gameResolution)

        # copy the hdd if it doesn't exist
        if not os.path.exists("/userdata/saves/xbox/xbox_hdd.qcow2"):
            if not os.path.exists("/userdata/saves/xbox"):
                os.makedirs("/userdata/saves/xbox")
            copyfile("/usr/share/xemu/data/xbox_hdd.qcow2", "/userdata/saves/xbox/xbox_hdd.qcow2")

        # the command to run
        commandArray = [xemuConfig.xemuBin]
        commandArray.extend(["-config_path", xemuConfig.xemuConfig])

        return Command(array=commandArray)

    def getInGameRatio(self, config, gameResolution, rom):
        if ("xemu_scaling" in config and config["xemu_scaling"] == "stretch") or ("xemu_aspect" in config and config["xemu_aspect"] == "16x9"):
            return 16/9
        return 4/3
