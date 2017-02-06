# FFMPEG tasks

child_process = require 'child_process'
fs = require 'fs'
ini = require 'ini'
path = require 'path'
jimp = require 'jimp'
temp = require 'temp'

ff_path = path.resolve __dirname, "../binaries/ffmpeg"

# Grab metadata from a file
module.exports.get_metadata = (file, callback)->
  command = ["-v", "error", "-i", file, "-f", "ffmetadata", "pipe:1"]
  child_process.execFile ff_path, command, (err, stdout)->
    return callback err if err
    return callback null, ini.parse stdout

# Get thumbnail
module.exports.get_thumb = (src, dest, width, height, callback)->
  command = ["-i", src, "-vframes", 1, "-an", "-vf", "scale='#{width}:-1',crop='h=min(#{height}\\,ih)'", dest]
  child_process.execFile ff_path, command, (err)->
    callback err

# Hash an image file, using jimp to assist. pHash
module.exports.hash = (img, callback)->
  tmp_output = temp.path {
                dir: path.dirname img
                suffix: ".bmp"
              }
  cleanup = (err, hash)->
    fs.unlinkSync tmp_output
    callback err, hash
  command = ["-v", "error", "-i", img, "-vf", "scale=32:32,hue=0:0", tmp_output]
  child_process.execFile ff_path, command, (err)->
    return cleanup err if err
    jimp.read tmp_output, (err, data)->
      return cleanup err if err
      cleanup null, data.hash()

# Jimp alone: 1550
# ffmpeg shrink to bmp first: 156

# Compare hashes for a match
# with underscore.string.levenshtein(<hash1>, <hash2>)
