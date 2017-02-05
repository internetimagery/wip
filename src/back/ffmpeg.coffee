# FFMPEG tasks

child_process = require 'child_process'
ini = require 'ini'
path = require 'path'

ff_path = path.resolve __dirname, "../binaries/ffmpeg"

# Grab metadata from a file
module.exports.get_metadata = (file, callback)->
  command = ["-v", "error", "-i", file, "-f", "ffmetadata", "pipe:1"]
  child_process.execFile ff_path, command, (err, stdout)->
    return callback err if err
    return callback null, ini.parse stdout
