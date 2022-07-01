# mapgen
Basic map generation with Simplex and Perlin Noise in Nim.

### Requirements
- nim
- nimPNG
- perlin
#### For the example program:
- cligen


### How to Build
```bash
git clone https://github.com/egeoz/mapgen.git
nimble install cligen nimPNG perlin
cd mapgen && nim c -d:release mapgenerator.nim

```

### Usage
```nim
import libmapgen

# MapGenerator* = object
#    width*, height*, iterationCount*: int
#    noiseSeed*: float
#    biome*: Biome
#    noise: NoiseType
#    output*: string
#    bottomElevation*, lowElevation*, midElevation*, highElevation*, topElevation*: uint8

# proc newMapGenerator*(width: int = 1920, height: int = 1080, output: string,
#                       biome: Biome = Temperate, noise: NoiseType = NoiseType.Simplex,
#                       noiseSeed: float = -0.2, iterationCount: int = 16, bottomElevation: uint8 = 185,
#                       lowElevation: uint8 = 170, midElevation: uint8 = 160, highElevation: uint8 = 145,
#                       topElevation: uint8 = 0): MapGenerator =
let mapgen = newMapGenerator(width = 1920,
                            height = 1080,
                            biome = Temperate,
                            noise = NoiseType.Simplex,
                            noiseSeed = -0.1,
                            output = "image.png")

# proc generateMap*(mapgen: MapGenerator) =
mapgen.generateMap()

# proc saveMap*(mapgen: MapGenerator) =
mapgen.saveMap()

# proc getMap*(mapgen: MapGenerator): seq[Pixel] =
var imgData = mapgen.getMap()

# proc getMapRGBA*(mapgen: MapGenerator): seq[uint8] =
imgData = mapgen.getMapRGBA() # Each pixel is [R, G, B, A]

```
### Example Program
```
Usage:
  mapgenerator [optional-params] [output: string...]
Options:
  -h, --help                  Display this help page.
  -v, --version  false        Show version info.
  -w=, --width=  1920         Width of the map to be generated.
  --height=      1080         Height of the map to be generated.
  -b=, --biome=  "temperate"  Biome type (arctic, temperate, desert).
  -p, --perlin   false        Use Perlin instead of Simplex noise.
```
### Examples
#### Simplex
- Temperate
<img src="https://github.com/egeoz/mapgen/blob/main/examples/temperate_simplex.png?raw=true" width="300">
- Arctic
<img src="https://github.com/egeoz/mapgen/blob/main/examples/arctic_simplex.png?raw=true" width="300">
- Desert
<img src="https://github.com/egeoz/mapgen/blob/main/examples/desert_simplex.png?raw=true" width="300">

#### Perlin
- Temperate
<img src="https://github.com/egeoz/mapgen/blob/main/examples/temperate_perlin.png?raw=true" width="300">
- Arctic
<img src="https://github.com/egeoz/mapgen/blob/main/examples/arctic_perlin.png?raw=true" width="300">
- Desert
<img src="https://github.com/egeoz/mapgen/blob/main/examples/desert_perlin.png?raw=true" width="300">


### TODO
- More biomes (ie. color schemes).
- Gradient color change for altitude.
- Threads
