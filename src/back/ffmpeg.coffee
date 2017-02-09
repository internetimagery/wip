# FFMPEG tasks

child_process = require 'child_process'
fs = require 'fs'
ini = require 'ini'
path = require 'path'
jimp = require 'jimp'

# Find our ffmpeg executable
ff_path = path.resolve __dirname, "../binaries/ffmpeg"

# Grab metadata from a file
metadata = (file, callback)->
  command = ["-v", "error", "-i", file, "-f", "ffmetadata", "pipe:1"]
  child_process.execFile ff_path, command, (err, meta)->
    return callback err if err
    return callback null, ini.parse meta

# Get thumbnail
thumb = (src, width, height, callback)->
  command = ["-v", "error", "-i", src, "-vframes", 1, "-an", "-vf", "scale='#{width}:-1',crop='h=min(#{height}\\,ih)'", "-f", "image2", "pipe:1"]
  child_process.execFile ff_path, command, {encoding: "buffer"}, (err, buffer)->
    callback err, buffer

# Hash an image file, using jimp to assist. pHash
hash = (img, callback)->
  command = ["-v", "error", "-i", img, "-vf", "scale=32:32,hue=0:0", "-f", "image2", "pipe:1"]
  child_process.execFile ff_path, command, {encoding: "buffer"}, (err, buffer)->
    return callback err if err
    jimp.read buffer, (err, data)->
      return callback err if err
      callback null, data.hash()

module.exports = {
  metadata: metadata
  thumb: thumb
  hash: hash
}

# Using ffmpeg to speed up jimp hashes
# Jimp alone: 1550
# ffmpeg shrink to bmp first: 156

# Compare hashes for a match
# with underscore.string.levenshtein(<hash1>, <hash2>)
