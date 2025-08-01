from generators.Generator import Generator
from Command import Command
import os

class SteamGenerator(Generator):
    # this emulator/core requires a X server to run
    def requiresX11(self):
        return True

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        basename = os.path.basename(rom)
        gameId = None
        if basename != "Steam.steam":
            # read the id inside the file
            with open(rom) as f:
                gameId = str.strip(f.read())

        if gameId is None:
            commandArray = ["batocera-steam"]
        else:
            commandArray = ["batocera-steam", gameId]
        return Command(array=commandArray)

    def getMouseMode(self, config, rom):
        return True
