# Repository containing photos, metadata etc etc


fs = require 'fs-extra'
path = require 'path'
Storage = require "./storage"
config = require "./config"

# Files saved in the format
# /metadata = database containing metadata
# /thumbs = folder containing thumbnails

class Repo
  constructor: ->
    @config_name = "config.json" # Name of file to find.
    db = null # Saving our data

  init: (base_path, callback)->
    # Load our config file. This file will tell us everything
    # about the repo from here.
    # If someone has changed the repo directory, we must rebuild it.
    # If no repo exists, build it.
    fs.ensureDir base_path, (err)=>
      return callback err if err
      config.load path.join(base_path, @config_name), (err, @config)=>
        return callback err if err
        # Initiate our thumnail directory
        @thumb_dir = path.join base_path, @config.repo, "thumbs"
        fs.ensureDir @thumb_dir, (err)=>
          return callback err if err
          # Initiate our Database
          @db = new Storage path.join(base_path, @config.repo, "metadata")
          # attempt to load our previous config information
          @db.get "config", (err, data)=>
            return callback err if err and err.name != "not_found"
            # Rebuild / Repair repo if config data changed
            @rebuild @config, data or {}, (err)->
              callback err

  rebuild: (new_config, old_config, callback)->
    # Rebuild repo if config data has changed
    # Get all values that changed [KEY, NEW_VAL, OLD_VAL]
    changes = ([k, v, old_config[k]] for k, v of new_config when old_config[k] != v)
    wait = changes.length
    done - (err)->
      return callback err if err
      wait -= 1
      if not wait
        callback null

    # TODO: make changes in new temporary repo then if success, move across

    # Loop through our changes and make adjustments
    for change in changes
      switch change[0]
        when value then something
        else done null


p = "D:/Documents/GitHub/wip/test/temp"
m = new Repo()
m.init p, (err)->
  console.error err if err
