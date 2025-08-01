from generators.Generator import Generator
from Command import Command
import os.path
from shutil import copytree
from . import ioquake3Config

class IOQuake3Generator(Generator):

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        ioquake3Config.writeCfgFiles(system, rom, playersControllers, gameResolution)

        # ioquake3 looks for folder either in config or from where it's launched
        source_dir = "/usr/bin/ioquake3"
        destination_dir = "/userdata/roms/quake3"
        destination_file = os.path.join(destination_dir, "ioquake3")
        source_file = os.path.join(source_dir, "ioquake3")
        # therefore copy latest ioquake3 file to rom directory
        if not os.path.isfile(destination_file) or os.path.getmtime(source_file) > os.path.getmtime(destination_file):
            copytree(source_dir, destination_dir, dirs_exist_ok=True)

        commandArray = ["/userdata/roms/quake3/ioquake3"]

        # get the game / mod to launch
        with open(rom, "r") as file:
            command_line = file.readline().strip()
            command_line_words = command_line.split()

        commandArray.extend(command_line_words)

        return Command(array=commandArray)

    def getInGameRatio(self, config, gameResolution, rom):
        if gameResolution["width"] / float(gameResolution["height"]) > ((16.0 / 9.0) - 0.1):
            return 16/9
        return 4/3
