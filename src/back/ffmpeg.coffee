# FFMPEG tasks

child_process = require 'child_process'
fs = require 'fs'
ini = require 'ini'
path = require 'path'
jimp = require 'jimp'

# Find our ffmpeg executable
ff_path = path.resolve __dirname, "../binaries/ffmpeg"

e = (cb1, cb2)-> return (err, args...)-> if err then cb1 err else cb2 args...

# Grab metadata from a file
metadata = (file, cb)->
  command = ["-v", "error", "-i", file, "-f", "ffmetadata", "pipe:1"]
  child_process.execFile ff_path, command, e cb, (meta)->
    return cb null, ini.parse meta

# Get thumbnail
thumb = (src, width, height, cb)->
  command = ["-v", "error", "-i", src, "-vframes", 1, "-an", "-vf", "scale='#{width}:-1',crop='h=min(#{height}\\,ih)'", "-f", "image2", "pipe:1"]
  child_process.execFile ff_path, command, {encoding: "buffer"}, (err, buffer)->
    cb err, buffer

# Hash an image file, using jimp to assist. pHash
hash = (img, cb)->
  command = ["-v", "error", "-i", img, "-vf", "scale=32:32,hue=0:0", "-f", "image2", "pipe:1"]
  child_process.execFile ff_path, command, {encoding: "buffer"}, e cb, (buffer)->
    jimp.read buffer, e cb, (data)->
      cb null, data.hash()

module.exports = {
  metadata: metadata
  thumb: thumb
  hash: hash
}

# Using ffmpeg to speed up jimp hashes
# Jimp alone: 1200ms
# ffmpeg shrink the bmp first: 175ms
