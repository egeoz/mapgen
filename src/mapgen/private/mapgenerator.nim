import 
  cligen,
  std/os,
  times,
  nimPNG,
  src/mapgen

const
  programName   = "mapgenerator"
  programVersion  = "0.1.0"

clCfg.helpSyntax = ""
clCfg.hTabCols = @[clOptKeys, clDflVal, clDescrip]
clCfg.version = programVersion

proc runMapGenerator(output: seq[string], width: int = 1920, height: int = 1080, biome: string = "temperate", perlin: bool = false) =
  let
    noiseType = if perlin: NoiseType.Perlin else: NoiseType.Simplex
    biomeType = if biome == "arctic": Arctic elif biome == "desert": Desert else: Temperate
    output = if output.len == 0: now().format("yyyy-MM-dd-HH-mm-ss").changeFileExt("png") else: output[0].changeFileExt("png")

    mg = newMapGenerator(
              width = width,
              height = height,
              biome = biomeType,
              noise = noiseType,
              noiseSeed = -0.1)

  mg.generateMap()
  discard savePNG24(output, mg.getMapRGB(), mg.width, mg.height)

when isMainModule:
  dispatch(runMapGenerator, cmdName = programName, help = {"help": "Display this help page.", "version": "Show version info.", "width": "Width of the map to be generated.", "height": "Height of the map to be generated.", "perlin": "Use Perlin instead of Simplex noise.", "biome": "Biome type (arctic, temperate, desert)."}, short = {"version": 'v', "biome": 'b', "perlin": 'p'})
