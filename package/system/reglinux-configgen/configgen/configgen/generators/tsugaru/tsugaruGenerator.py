from generators.Generator import Generator
from Command import Command
import os
from . import tsugaruConfig

class TsugaruGenerator(Generator):
    # this emulator/core requires a X server to run
    def requiresX11(self):
        return True

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):

	# Start emulator fullscreen
        commandArray = [tsugaruConfig.tsugaruBin, "/userdata/bios/fmtowns"]
        commandArray += ["-AUTOSCALE", "-HIGHRES", "-NOWAITBOOT"]
        commandArray += ["-GAMEPORT0", "KEY"]
        commandArray += ["-KEYBOARD", "DIRECT"]
        commandArray += ["-PAUSEKEY", "F10"]

        # CD Speed
        if system.isOptSet('cdrom_speed') and system.config['cdrom_speed'] != 'auto':
            commandArray += ["-CDSPEED", system.config["cdrom_speed"]]

        # CPU Emulation
        if system.isOptSet('386dx') and system.config['386dx'] == '1':
            commandArray += ["-PRETEND386DX"]

        extension = os.path.splitext(rom)[1][1:].lower()
        if extension in ['iso', 'cue', 'bin']:
            # Launch CD-ROM
            commandArray += ["-CD", rom]
        else:
            # Launch floppy
            commandArray += ["-FD0", rom]

        return Command(array=commandArray)
