# FFMPEG tasks

child_process = require 'child_process'
Promise = require 'promise'
ini = require 'ini'
path = require 'path'
jimp = require 'jimp'

# Find our ffmpeg executable
ff_path = path.resolve __dirname, "../binaries/ffmpeg"

execFile = Promise.denodeify child_process.execFile
read = Promise.denodeify jimp.read

# Grab metadata from a file
metadata = (file)->
  command = ["-v", "error", "-i", file, "-f", "ffmetadata", "pipe:1"]
  execFile ff_path, command
  .then (meta)->
    ini.parse meta

# Get thumbnail
thumb = (src, width, height)->
  command = ["-v", "error", "-i", src, "-vframes", 1, "-an", "-vf", "scale='#{width}:-1',crop='h=min(#{height}\\,ih)'", "-f", "image2", "pipe:1"]
  execFile ff_path, command, {encoding: "buffer"}

# Hash an image file, using jimp to assist. pHash
hash = (img)->
  command = ["-v", "error", "-i", img, "-vf", "scale=32:32,hue=0:0", "-f", "image2", "pipe:1"]
  execFile ff_path, command, {encoding: "buffer"}
  .then (buffer)->
    read buffer
  .then (data)->
    data.hash()

module.exports = {
  metadata: metadata
  thumb: thumb
  hash: hash
}

# Using ffmpeg to speed up jimp hashes
# Jimp alone: 1200ms
# ffmpeg shrink the bmp first: 175ms
