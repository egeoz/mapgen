# mapgen
Basic map generation with Simplex and Perlin Noise in Nim

### Requirements
- nim
- clapfn
- nimPNG
- perlin


### How to Build
```bash
git clone https://github.com/egeoz/mapgen.git
nimble install clapfn nimPNG perlin
cd mapgen && nim c -d:release mapgenerator.nim

```

### Usage

```
Fantasy Map Generator v0.0.1
Generate imaginary maps with Simplex Noise

Usage: mapgenerator [-h] [-v] [-b=temperate] [-i=16] [-l=0.008] [-o=output] [-s=2048] [-p] [-m]

Required arguments:


Optional arguments:
    -h, --help                       Show this help message and exit.
    -v, --version                    Show version number and exit.
    -b=temperate, --biome=temperate  Set the color scheme of the map (arctic, desert, mars, temperate).
    -i=16, --iteration=16            Specify the number of Simplex iterations (increases sharpness).
    -l=0.008, --landmassscale=0.008  Specify the scale of landmasses (default is 0.008).
    -o=output, --output=output       Specify the output file name.
    -s=2048, --size=2048             Specify the size of the map in pixels.
    -p, --perlin                     Generate with Perlin noise algorithm instead.
    -m, --heightmap                  Create a heightmap.
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
- ...
