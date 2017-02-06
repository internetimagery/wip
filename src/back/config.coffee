# Config file

fs = require 'fs'
path = require 'path'

# Default settings for config!
CONFIG_DEFAULTS =

  # Name of the repo, holding metadata and thumbnails etc
  # Can be relative or absolute file name
  repo: ".data"

  # Format to generate paths, to save photos / videos
  # Relative path names only
  path_format: "{YYYY}/{YY}-{MM}-{DD} {EVENT}/{YY}-{MM}-{DD} {EVENT}{NUM}{TAGS}{EXT}"

  # How close do we consider a match to alert the user of a conflict
  # 0 = perfect match. 10+ Noooo waaay
  duplicate_closeness: 0.3


# Load a config file if it exists.
# Otherwise create a new one with our defaults
module.exports.load = (f_path, callback)->
  fs.readFile f_path, "utf8", (err, data)->
    if err
      return callback err if err.code != "ENOENT"
      fs.writeFile f_path, JSON.stringify(CONFIG_DEFAULTS), (err)->
        return callback err, CONFIG_DEFAULTS
    else
      try
        callback null, JSON.parse data
      catch err
        callback err
