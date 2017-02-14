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

# reimagined:
#   add = files, added to stash
#   stash = list files in stash
#   update = make changes to the files doc, stick
#   commit = add files from stash into repo
#   delete = delete a doc, and the file at "path"
#   read = get all info from a doc. pass in a boolean to also get thumnail perhaps

# States
STASHED = 2
STORED = 1
MISSING = 0

class Repo
  constructor: (@root)->
    # Load database
    @db = new Storage path.join @root, config.dir.db

  add: (images...)->
    # Add images to stash
    @config().then (conf)->
      photos_dir = path.join @root, conf.dir.photos
      stash_dir = path.join @root, conf.dir.stash
      docs = Array images.length
      eachOfLimit images, conf.max_processes, (img, i, done)=>
        fs.stat img
        .then (stats)->
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
          copy img, doc.path
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

  list: (key)->
    # List files currently in stash
  update: (changes)->
    # Edit docs for files
  commit: (message)->
    # Move images from stash to repo
  delete: (doc)->
    # Remove doc, and physical file
  read: (id)->
    # Get data from doc via id
  thumb: (id)->
    # Get thumbnail
  config: ->
    # get config doc, or add defaults if not yet installed
    @db.get config._id
    .catch (err)->
      throw err if err.name != "not_found"
      @db.put config
      config


  # Initiate the database.
  # Grab the repo config file. If it exists, otherwise use defaults.
  init: (@root)->
    @db = new storage path.join @root, config.dir.db
    @db.get config._id
    .catch (err)=>
      throw err if err.name != "not_found"
      @db.put config
    .then (doc)=>
      @config = doc

  # Build a valid photo entry for our database
  get_doc: (photo, date=new Date(), event="Unsorted", tags=[])->
    doc =
      _id: utility.unique_id().toString()
      src: photo
      date: date.toISOString()
      event: event
      tags: tags
    return doc

  # Add photos to the repo
  # Accepts one or more docs!
  add: (docs)->
    new_docs = []
    docs = [docs] if not Array.isArray docs
    photos_dir = path.join @root, @config.dir.photos
    eachLimit docs, @config.max_processes, (doc, done)=>
      # Build a path name.
      metadata ={}
      metadata[k] = v for k, v of doc
      metadata[k] = v for k, v of utility.extract_date new Date(doc.date)
      metadata.tags = metadata.tags.join " "
      doc.path = utility.build_path @config.photos.format, metadata
      doc.path += path.extname doc.src
      path_abs = path.join photos_dir, doc.path

      # Get a hash of the file
      # Create a thumbnail
      # Copy the file into its new location
      Promise.all [
        ffmpeg.hash doc.src
        ffmpeg.thumb doc.src, @config.thumbs.width, @config.thumbs.height
        copy doc.src, path_abs
        ]
      .then (results)=>
        # Add our Hash and Thumbnail attachment to our document
        # Put the document into the database finally.
        doc.hash = results[0]
        @db.put doc
        .then (doc)=>
          @db.put_attachment doc, @config.thumbs.name, @config.thumbs.type, results[1]
        .then (doc)->
          new_docs.push doc
          done()
      .catch done
    .then ->
      new_docs

module.exports = Repo

#
#
# p = "D:/Documents/GitHub/wip/test/temp"
# i = "D:/Documents/GitHub/wip/test/test_data/img_a.jpg"
# m = new Repo()
# m.init p, (err)->
#   return console.error err if err
#   doc = m.get_doc i, new Date(), "birthday", ["person", "people"]
#   m.add [doc], (err, docs)->
#     return console.error err if err
#     m.db.get_thumb docs[0], "thumb.jpeg", (err, thumb)->
#       return console.error err if err
#       fs.writeFile path.join(p, "test2.jpeg"), thumb, (err)->
#         console.error err if err
