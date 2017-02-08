# Repository collecting photos, metadata etc etc

fs = require 'fs-extra'
path = require 'path'
async = require 'async'
temp = require 'temp'
string = require 'underscore.string'
storage = require "./storage"
utility = require "./utility"
ffmpeg = require "./ffmpeg"
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

  # Build a valid photo entry for our database
  get_doc: (photo, date=new Date(), event="Unsorted", tags=[])->
    doc =
      id: utility.unique_id()
      src: photo
      date: date.toUTCString()
      event: event
      tags: tags.join " "
    return doc

  # Add photos to the repo
  # Accepts one or more docs!
  add: (docs, callback)->
    docs = [docs] if not Array.isArray docs
    photos_dir = path.join @root, @config.dir.photos
    for doc in docs
      do (doc)=>
        # Build a path name.
        metadata ={}
        metadata[k] = v for k, v of doc
        metadata[k] = v for k, v of utility.extract_date new Date(doc.date)
        doc.path = utility.build_path @config.photos.format, metadata
        doc.path += path.extname doc.src
        path_abs = path.join photos_dir, doc.path

        # Get a hash of the file
        # Create a thumbnail
        # Copy the file into its new location
        async.parallel [
          async.apply ffmpeg.hash, doc.src
          async.apply ffmpeg.thumb, doc.src, temp.path({suffix:".jpg"}), @config.thumbs.width, @config.thumbs.height
          async.apply fs.copy, doc.src, path_abs
        ], (err, results)->
          return callback err if err
          console.log fs.readFile results[1]
          fs.unlinkSync(results[1])
          console.log results




p = "D:/Documents/GitHub/wip/test/temp"
i = "D:/Documents/GitHub/wip/test/test_data/img_a.jpg"
m = new Repo()
m.init p, (err)->
  return console.error err if err
  doc = m.get_doc i, new Date(), "birthday", ["person", "people"]
  m.add [doc], (err, doc)->
    return console.error err if err
    console.log "doc", doc
