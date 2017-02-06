# Image manipulation

jimp = require 'jimp'

# ffmpeg scale and desaturate =
# -vf scale=32:32,hue=0:0

# Hashing, thanks to JIMP
# https://github.com/oliver-moran/jimp/blob/master/index.js

intToRGBA = (i)->
    rgba = {}
    rgba.r = Math.floor(i / Math.pow(256, 3))
    rgba.g = Math.floor((i - (rgba.r * Math.pow(256, 3))) / Math.pow(256, 2))
    rgba.b = Math.floor((i - (rgba.r * Math.pow(256, 3)) - (rgba.g * Math.pow(256, 2))) / Math.pow(256, 1))
    rgba.a = Math.floor((i - (rgba.r * Math.pow(256, 3)) - (rgba.g * Math.pow(256, 2)) - (rgba.b * Math.pow(256, 1))) / Math.pow(256, 0))
    return rgba

c = []
initCoefficients = (size)->
  for i in [0 ... size]
    c[i] = 1
  c[0] = 1 / Math.sqrt 2.0

applyDCT = (f, size)->
  N = size
  F = []
  for u in [0 ... N]
    F[u] = []
    for v in [0 ... N]
      sum = 0
      for i in [0 ... N]
        for j in [0 ... N]
          a = Math.cos(((2 * i + 1) / (2.0 * N)) * u * Math.PI)
          b = Math.cos(((2 * j + 1) / (2.0 * N)) * v * Math.PI)
          sum += a * b * f[i][j]
    sum *= (c[u] * c[v]) / 4
    f[u][v] = sum
  return F


# Jimp.prototype.getPixelColor = Jimp.prototype.getPixelColour = function (x, y, cb) {
#     if ("number" != typeof x || "number" != typeof y)
#         return throwError.call(this, "x and y must be numbers", cb);
#
#     // round input
#     x = Math.round(x);
#     y = Math.round(y);
#
#     var idx = this.getPixelIndex(x, y);
#     var hex = this.bitmap.data.readUInt32BE(idx);
#
#     if (isNodePattern(cb)) return cb.call(this, null, hex);
#     else return hex;
# };
# Jimp.prototype.getPixelIndex = function (x, y, edgeHandling, cb) {
#     var xi, yi;
#     if ("function" == typeof edgeHandling && "undefined" == typeof cb) {
#         cb = edgeHandling;
#         edgeHandling = null;
#     }
#     if (!edgeHandling) edgeHandling = Jimp.EDGE_EXTEND;
#     if ("number" != typeof x || "number" != typeof y)
#         return throwError.call(this, "x and y must be numbers", cb);
#
#     // round input
#     xi = x = Math.round(x);
#     yi = y = Math.round(y);
#
#     if (edgeHandling = Jimp.EDGE_EXTEND) {
#         if (x<0) xi = 0;
#         if (x>=this.bitmap.width) xi = this.bitmap.width - 1;
#         if (y<0) yi = 0;
#         if (y>=this.bitmap.height) yi = this.bitmap.height - 1;
#     }
#     if (edgeHandling = Jimp.EDGE_WRAP) {
#         if (x<0) xi = this.bitmap.width + x;
#         if (x>=this.bitmap.width) xi = x % this.bitmap.width;
#         if (y<0) xi = this.bitmap.height + y;
#         if (y>=this.bitmap.height) yi = y % this.bitmap.height;
#     }
#
#     var i = (this.bitmap.width * yi + xi) << 2;
#
#     // if out of bounds index is -1
#     if (xi < 0 || xi >= this.bitmap.width) i = -1;
#     if (yi < 0 || yi >= this.bitmap.height) i = -1;
#
#     if (isNodePattern(cb)) return cb.call(this, null, i);
#     else return i;
# };



# Hash an image, pHash
module.exports.hash = (img, callback)->
  jimp.read img, (err, data)->
    return callback err if err
    callback null, data.hash()

# Compare hashes, hamming distance
module.exports.compare = (hashA, hashB, callback)->
  try
    callback null, jimp.distance hashA, hashB
  catch err
    callback err

p = "D:/Documents/GitHub/wip/test/test_data/img2.jpg"
# module.exports.hash p, (err, hash)->
#   console.log err
#   console.log hash
fs = require 'fs'
jpeg = require 'jpeg-js'
# blockhash = require 'blockhash'
fs.readFile p, (err, data)->
  return console.error err if err
  img_data = jpeg.decode data
  console.log img_data

  vals = []
  for x in [0 ... 32]
    vals[x] = []
    for y in [0 ... 32]
      vals[x][y] = intToRGBA(getPixelColor(x, y)).b

  dctVals = applyDCT vals, 32

  total = 0
  for x in [0 ... 8]
    for y in [0 ... 8]
      total += dctVals[x][y]

  avg = total / (8 * 8)

  hash = ""
  count = 0
  for x in [0 ... 8]
    for y in [0 ... 8]
      hash += if dctVals[x][y] > avg then "1" else "0"

  console.log hash
