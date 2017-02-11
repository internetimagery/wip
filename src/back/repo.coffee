# Repository collecting photos, metadata etc etc

fs = require 'fs-extra'
path = require 'path'
async = require 'async'
temp = require 'temp'
Promise = require 'promise'
string = require 'underscore.string'
storage = require "./storage"
utility = require "./utility"
ffmpeg = require "./ffmpeg"
config = require "./config.json"

eachLimit = Promise.denodeify async.eachLimit
copy = Promise.denodeify fs.copy

class Repo
  # Give the repo a name
  constructor: (@name)->

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
