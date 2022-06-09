import clapfn, tables, perlin, random, math, nimPNG, strutils, times, std/os

var parser = ArgumentParser(programName: "Map Generator", fullName: "Fantasy Map Generator",
                            description: "Generate imaginary maps with Simplex Noise", version: "0.0.1",
                            author: "")

parser.addStoreArgument(shortName = "-o", longName = "--output", usageInput = "output", default = "yyyy-MM-dd-hh-mm-ss", help = "Specify the output file name.")
parser.addStoreArgument(shortName = "-s", longName = "--size", usageInput = "2048", default = "2048", help = "Specify the size of the map in pixels.")
parser.addStoreArgument(shortName = "-b", longName = "--biome", usageInput = "temperate", default = "temperate", help = "Set the color scheme of the map (arctic, desert, mars, temperate).")
parser.addStoreArgument(shortName = "-l", longName = "--landmassscale", usageInput = "0.008", default = "0.008", help = "Specify the scale of landmasses (default is 0.008).")
parser.addStoreArgument(shortName = "-i", longName = "--iteration", usageInput = "16", default = "16", help = "Specify the number of Simplex iterations (increases sharpness).")
parser.addSwitchArgument(shortName = "-m", longName = "--heightmap", default = false, help = "Create a heightmap.")
parser.addSwitchArgument(shortName = "-p", longName = "--perlin", default = false, help = "Generate with Perlin noise algorithm instead.")

randomize()

let args = parser.parse()
let noise = newNoise()
let size = parseInt(args["size"])
let scale = parseFloat(args["landmassscale"])
let iterationCount = parseInt(args["iteration"])
var fileName = changeFileExt(args["output"], "")

# todo add deep elevations
type
    Biome = object
        bottomElevationsRed:    uint8
        bottomElevationsGreen:  uint8
        bottomElevationsBlue:   uint8        

        lowElevationsRed:    uint8
        lowElevationsGreen:  uint8
        lowElevationsBlue:   uint8

        midElevationsRed:    uint8
        midElevationsGreen:  uint8
        midElevationsBlue:   uint8

        highElevationsRed:   uint8
        highElevationsGreen: uint8
        highElevationsBlue:  uint8

        topElevationsRed:   uint8
        topElevationsGreen: uint8
        topElevationsBlue:  uint8

const bottomElevation = 185
const lowElevation = 170
const midElevation = 160
const highElevation = 145
const topElevation = 0

var temperate = Biome(bottomElevationsRed: 20, bottomElevationsGreen: 70, bottomElevationsBlue: 135,
                    lowElevationsRed: 20, lowElevationsGreen: 100, lowElevationsBlue: 155,
                    midElevationsRed: 20, midElevationsGreen: 70, midElevationsBlue: 20,
                    highElevationsRed: 70, highElevationsGreen: 70, highElevationsBlue: 20,
                    topElevationsRed: 50, topElevationsGreen: 35, topElevationsBlue: 20)

var arctic = Biome(bottomElevationsRed: 20, bottomElevationsGreen: 70, bottomElevationsBlue: 135,
                    lowElevationsRed: 20, lowElevationsGreen: 100, lowElevationsBlue: 155,
                    midElevationsRed: 190, midElevationsGreen: 210, midElevationsBlue: 255,
                    highElevationsRed: 240, highElevationsGreen: 240, highElevationsBlue: 240,
                    topElevationsRed: 255, topElevationsGreen: 255, topElevationsBlue: 255)

var desert = Biome(bottomElevationsRed: 20, bottomElevationsGreen: 70, bottomElevationsBlue: 135,
                    lowElevationsRed: 20, lowElevationsGreen: 100, lowElevationsBlue: 155,
                    midElevationsRed: 225, midElevationsGreen: 200, midElevationsBlue: 155,
                    highElevationsRed: 170, highElevationsGreen: 155, highElevationsBlue: 120,
                    topElevationsRed: 50, topElevationsGreen: 35, topElevationsBlue: 20)

proc normalize(lowerBound: int, upperBound: int, value: float): int =
    return int(value * (upperBound - lowerBound).float / 2 + (upperBound + lowerBound).float / 2)

proc iterateSimplex(x: int, y: int): uint8 =
    var value, maxAmp, amp, freq: float
    
    value = - 0.2   
    maxAmp = 0.0
    amp = 1.0
    freq = scale

    for i in 0 .. iterationCount:
        value += noise.simplex(x.float * freq, y.float * freq) * amp
        maxAmp += amp
        amp *= 0.5
        freq *= 2

    return uint8(normalize(0, 255, value / maxAmp))

proc iteratePerlin(x: int, y: int): uint8 =
    var value, maxAmp, amp, freq: float

    value = - 0.2
    maxAmp = 0.0
    amp = 1.0
    freq = scale

    for i in 0 .. iterationCount:
        value += noise.perlin(x.float * freq, y.float * freq) * amp
        maxAmp += amp
        amp *= 0.5
        freq *= 2

    return uint8(normalize(0, 255, value / maxAmp))


proc generateMap(): seq[uint8] =
    var pixels = newSeq[uint8](size * size)
    var pixels8index = 0

    for x in 0 ..< size:
        for y in 0 ..< size:
            if parseBool(args["perlin"]): pixels[pixels8index] = iteratePerlin(x, y) else: pixels[pixels8index] = iterateSimplex(x, y)
            inc pixels8index

    return pixels


proc convertToRGB(pixels: seq[uint8]): seq[uint8] =
    var pixelsRGB = newSeq[uint8](size * size * 3)
    var pixels8index = 0
    var currentBiome: Biome

    case args["biome"]:
        of "temperate":
            currentBiome = temperate
        of "arctic":
            currentBiome = arctic
        of "desert":
            currentBiome = desert
        of "mars":
            currentBiome = temperate
        else: 
            currentBiome = temperate

    for i in countup(0, pixelsRGB.high, 3):
        if pixels[pixels8index] >= topElevation and pixels[pixels8index] <= highElevation:
            pixelsRGB[i] = currentBiome.topElevationsRed
            pixelsRGB[i + 1] = currentBiome.topElevationsGreen
            pixelsRGB[i + 2] = currentBiome.topElevationsBlue
        elif pixels[pixels8index] >= highElevation and pixels[pixels8index] <= midElevation:
            pixelsRGB[i] = currentBiome.highElevationsRed
            pixelsRGB[i + 1] = currentBiome.highElevationsGreen
            pixelsRGB[i + 2] = currentBiome.highElevationsBlue
        elif pixels[pixels8index] >= midElevation and pixels[pixels8index] <= lowElevation:
            pixelsRGB[i] = currentBiome.midElevationsRed
            pixelsRGB[i + 1] = currentBiome.midElevationsGreen
            pixelsRGB[i + 2] = currentBiome.midElevationsBlue        
        elif pixels[pixels8index] >= lowElevation and pixels[pixels8index] <= bottomElevation:
            pixelsRGB[i] = currentBiome.lowElevationsRed
            pixelsRGB[i + 1] = currentBiome.lowElevationsGreen
            pixelsRGB[i + 2] = currentBiome.lowElevationsBlue
        else:
            pixelsRGB[i] = currentBiome.bottomElevationsRed
            pixelsRGB[i + 1] = currentBiome.bottomElevationsGreen
            pixelsRGB[i + 2] = currentBiome.bottomElevationsBlue

        inc pixels8index

    return pixelsRGB

proc convertToGrayscale(pixels: seq[uint8]): seq[uint8] =
    var pixelsGray = newSeq[uint8](size * size * 3)
    var pixels8index = 0

    for i in countup(0, pixelsGray.high, 3):
        pixelsGray[i] = pixels[pixels8index]
        pixelsGray[i + 1] = pixels[pixels8index]
        pixelsGray[i + 2] = pixels[pixels8index]

        inc pixels8index

    return pixelsGray

proc init() =
    let pixels8 = generateMap()
    
    if fileName == "yyyy-MM-dd-hh-mm-ss":
        fileName = now().format("yyyy-MM-dd-hh-mm-ss")

    if parseBool(args["heightmap"]): 
        discard savePNG24(fileName & "_heightmap.png", convertToGrayscale(pixels8), size, size)

    discard savePNG24(fileName & ".png", convertToRGB(pixels8), size, size)


init()

