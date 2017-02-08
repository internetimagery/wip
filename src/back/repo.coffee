# Repository collecting photos, metadata etc etc

fs = require 'fs-extra'
path = require 'path'
storage = require "./storage"
utility = require "./utility"

# Load up some default data for the repo!
config = require "./config.json"

class Repo
  # Give the repo a name
  constructor: (@name)->

  # Initiate the database.
  # Grab the repo config file. If it exists, otherwise use defaults.
  init: (@root, callback)->
    @db = new storage path.join @root, config.dir.db
    @db.get config.id, (err, doc)=>
      return callback err if err and err.name != "not_found"
      if err # We have not yet added a config file to the DB
        @db.put config, (err, doc)=>
          return callback err if err
          @config = doc
          callback null
      else
        @config = doc
        callback null

  # Add a photo to the repo
  add: (photo, date, metadata, callback)->
    metadata[k] = v for k, v of utility.extract_date date
    console.log utility.build_path @config.photos.format, metadata


p = "D:/Documents/GitHub/wip/test/temp"
i = "D:/Documents/GitHub/wip/test/test_data/img_a.jpg"
m = new Repo()
m.init p, (err)->
  return console.error err if err
  m.add i, new Date(), {event: "birthday", tags:"person people"}, (err, id)->
    return console.error err if err
    console.log "id", id
