# Repository collecting photos, metadata etc etc

path = require 'path'
temp = require 'temp'
Promise = require 'promise'
string = require 'underscore.string'
Storage = require "./storage"
utility = require "./utility"
ffmpeg = require "./ffmpeg"
config = require "./config.json"
fs = require "./fs"
eachOfLimit = Promise.denodeify require "async/eachOfLimit"

# Document states
STASHED = 2
STORED = 1
MISSING = 0

class Repo
  constructor: (@root)->
    # Load database
    @db = new Storage path.join @root, config.dir.db

  add: (images...)->
    # Add images to stash
    @_config().then (conf)=>
      photos_dir = path.join @root, conf.dir.photos
      stash_dir = path.join @root, conf.dir.stash
      docs = Array images.length
      eachOfLimit images, conf.max_processes, (img, i, done)=>
        fs.stat img
        .then (stats)=>
          # TODO: Extract date from image

          # Build our metadata document
          doc = {
            _id: utility.unique_id().toString()
            src: img
            path: temp.path {dir: stash_dir, suffix: path.extname img}
            date: new Date() # Get from exif if possible.
            event: ""
            tags: []
            size: stats.size
            state: STASHED
          }

          # Hash the image.
          # Create a thumbnail
          # Copy the file into the stash
          Promise.all [
            ffmpeg.hash img
            ffmpeg.thumb img, conf.thumbs.width, conf.thumbs.height
            fs.copy img, doc.path
          ]
          .then (results)=>
            doc.hash = results[0]
            @db.put doc
            .then (doc)=>
              @db.put_attachment doc, conf.thumbs.name, conf.thumbs.type, results[1]
            .then (doc)=>
              docs[i] = doc
              done()
          .catch done
      .then ->
        docs

  list: (view)->
    # List precompiled view
    new Promise (ok, fail)->
      @db.query view
      .then (docs)->
        ok docs
      .catch (err)=>
        return fail err if err.name != "not_found"
        func = switch view
          when "hash" then (doc)-> emit doc.hash if doc.hash?
          else throw new Error "view not compiled \"#{view}\"."
        @db.compile view, func
        .then =>
          @db.query view
        .then (docs)->
          console.log docs
          docs


  update: (doc)->
    # Edit docs for files
    @db.put doc

  commit: (message)->
    # Move images from stash to repo
    console.log "move files into repo!"

  delete: (doc)->
    # Remove doc, and physical file
    @db.del doc

  read: (id)->
    # Get data from doc via id
    @db.get id
    .then (doc)->
      doc.date = new Date(doc.date) if doc.date?
      doc

  thumb: (id)->
    # Get thumbnail
    @_config().then (conf)=>
      @db.get_attachment id, conf.thumbs.name

  _config: ->
    # get config doc, or add defaults if not yet installed
    @db.get config._id
    .catch (err)=>
      throw err if err.name != "not_found"
      @db.put config
    .then (config)->
      config


module.exports = Repo
