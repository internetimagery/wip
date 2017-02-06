# Config file

fs = require 'fs'
path = require 'path'

config_path = path.resolve __dirname, "../config_defaults.json"

# Load a config file if it exists.
# Otherwise create a new one with our defaults
module.exports.load = (f_path, callback)->
  fs.readFile f_path, "utf8", (err, data)->
    if err
      return callback err if err.code != "ENOENT"
      fs.readFile config_path, "utf8", (err, data)->
        return callback err if err
        try
          config = JSON.parse data
          fs.writeFile f_path, data, (err)->
            callback err, config
        catch err
            callback err
    else
      try
        callback null, JSON.parse data
      catch err
        callback err
