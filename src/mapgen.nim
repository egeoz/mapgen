import  
  perlin,
  random

type
  Biome* = object
    bottomElevationsRed*:   uint8
    bottomElevationsGreen*: uint8
    bottomElevationsBlue*:  uint8

    lowElevationsRed*:      uint8
    lowElevationsGreen*:    uint8
    lowElevationsBlue*:     uint8

    midElevationsRed*:      uint8
    midElevationsGreen*:    uint8
    midElevationsBlue*:     uint8

    highElevationsRed*:     uint8
    highElevationsGreen*:   uint8
    highElevationsBlue*:    uint8

    topElevationsRed*:      uint8
    topElevationsGreen*:    uint8
    topElevationsBlue*:     uint8

  Pixel* = object
    R, G, B: uint8

  NoiseType* = enum
    Simplex,
    Perlin

  MapGenerator* = object
    width*, height*, iterationCount*: int
    noiseSeed*: float
    biome*: Biome
    noise: NoiseType
    bottomElevation*, lowElevation*, midElevation*, highElevation*, topElevation*: uint8

var 
  Arctic* = Biome(bottomElevationsRed: 20, bottomElevationsGreen: 70, bottomElevationsBlue: 135,
                  lowElevationsRed: 20, lowElevationsGreen: 100, lowElevationsBlue: 155,
                  midElevationsRed: 190, midElevationsGreen: 210, midElevationsBlue: 255,
                  highElevationsRed: 240, highElevationsGreen: 240, highElevationsBlue: 240,
                  topElevationsRed: 255, topElevationsGreen: 255, topElevationsBlue: 255)

  Desert* = Biome(bottomElevationsRed: 20, bottomElevationsGreen: 70, bottomElevationsBlue: 135,
                  lowElevationsRed: 20, lowElevationsGreen: 100, lowElevationsBlue: 155,
                  midElevationsRed: 225, midElevationsGreen: 200, midElevationsBlue: 155,
                  highElevationsRed: 170, highElevationsGreen: 155, highElevationsBlue: 120,
                  topElevationsRed: 50, topElevationsGreen: 35, topElevationsBlue: 20)

  Temperate* = Biome(bottomElevationsRed: 20, bottomElevationsGreen: 70, bottomElevationsBlue: 135,
                     lowElevationsRed: 20, lowElevationsGreen: 100, lowElevationsBlue: 155,
                     midElevationsRed: 20, midElevationsGreen: 70, midElevationsBlue: 20,
                     highElevationsRed: 70, highElevationsGreen: 70, highElevationsBlue: 20,
                     topElevationsRed: 50, topElevationsGreen: 35, topElevationsBlue: 20)

  mapSeq: seq[Pixel]
  noise: Noise

proc newMapGenerator*(width: int = 1920, height: int = 1080, biome: Biome = Temperate, noise: NoiseType = NoiseType.Simplex, noiseSeed: float = -0.2, iterationCount: int = 16, bottomElevation: uint8 = 185, lowElevation: uint8 = 170, midElevation: uint8 = 160, highElevation: uint8 = 145, topElevation: uint8 = 0): MapGenerator =
  result = MapGenerator(width: width,
                        height: height,
                        biome: biome,
                        noise: noise,
                        noiseSeed: noiseSeed,
                        iterationCount: iterationCount,
                        bottomElevation: bottomElevation,
                        lowElevation: lowElevation,
                        midElevation: midElevation,
                        highElevation: highElevation,
                        topElevation: topElevation)

proc serialize(mapSeq: seq[Pixel]): seq[uint8] =
  for pixel in mapSeq:
    result.add(pixel.R)
    result.add(pixel.G)
    result.add(pixel.B)

proc coordToPos(mapgen: MapGenerator, coordx, coordy: int): int =
  var cx, cy: int
  cx = coordx mod mapgen.width
  cy = coordy mod mapgen.height
  result = (cy * mapgen.width) + cx

proc normalize(lowerBound, upperBound: int, value: float): int =
  result = int(value * (upperBound - lowerBound).float / 2 + (upperBound + lowerBound).float / 2)

proc iterateNoise(mapgen: MapGenerator, x, y: int): uint8 =
  var
    value = mapgen.noiseSeed
    maxAmp = 0.0
    amp = 1.0
    freq = 0.008

  for i in 0 .. mapgen.iterationCount:
    if mapgen.noise == NoiseType.Simplex: value += noise.simplex(x.float * freq, y.float * freq) * amp
    else: value += noise.perlin(x.float * freq, y.float * freq) * amp
    maxAmp += amp
    amp *= 0.5
    freq *= 2

  result = uint8(normalize(0, 255, value / maxAmp))

proc colorizeMap(mapgen: MapGenerator, val: uint8): Pixel =
  var r, g, b: uint8

  if val >= mapgen.topElevation and val <= mapgen.highElevation:
    (r, g, b) = (mapgen.biome.topElevationsRed, mapgen.biome.topElevationsGreen, mapgen.biome.topElevationsBlue)
  elif val >= mapgen.highElevation and val <= mapgen.midElevation:
    (r, g, b) = (mapgen.biome.highElevationsRed, mapgen.biome.highElevationsGreen, mapgen.biome.highElevationsBlue)
  elif val >= mapgen.midElevation and val <= mapgen.lowElevation:
    (r, g, b) = (mapgen.biome.midElevationsRed, mapgen.biome.midElevationsGreen, mapgen.biome.midElevationsBlue)
  elif val >= mapgen.lowElevation and val <= mapgen.bottomElevation:
    (r, g, b) = (mapgen.biome.lowElevationsRed, mapgen.biome.lowElevationsGreen, mapgen.biome.lowElevationsBlue)
  else:
    (r, g, b) = (mapgen.biome.bottomElevationsRed, mapgen.biome.bottomElevationsGreen, mapgen.biome.bottomElevationsBlue)

  result = Pixel(R: r, G: g, B: b)

proc generateMap*(mapgen: MapGenerator) =
  randomize()
  mapSeq = newSeq[Pixel](mapgen.width * mapgen.height)
  noise = newNoise()
  for x in 0 ..< mapgen.width:
    for y in 0 ..< mapgen.height:
      mapSeq[mapgen.coordToPos(x, y)] = mapgen.colorizeMap(mapgen.iterateNoise(x, y))

proc getMap*(mapgen: MapGenerator): seq[Pixel] =
  result = mapSeq

proc getMapRGB*(mapgen: MapGenerator): seq[uint8] =
  result = mapSeq.serialize()


