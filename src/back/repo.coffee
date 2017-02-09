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
    @db.get config._id, (err, doc)=>
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
      _id: utility.unique_id().toString()
      src: photo
      date: date.toUTCString()
      event: event
      tags: tags
    return doc

  # Add photos to the repo
  # Accepts one or more docs!
  add: (docs, callback)->
    new_docs = []
    docs = [docs] if not Array.isArray docs
    photos_dir = path.join @root, @config.dir.photos
    async.eachLimit docs, @config.max_processes, (doc, done)=>
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
      async.parallel [
        async.apply ffmpeg.hash, doc.src
        async.apply ffmpeg.thumb, doc.src, @config.thumbs.width, @config.thumbs.height
        async.apply fs.copy, doc.src, path_abs
      ], (err, results)=>
        return done err if err

        # Add our Hash and Thumbnail attachment to our document
        # Put the document into the database finally.
        doc.hash = results[0]
        @db.put doc, (err, doc)=>
          return done err if err
          @db.add_attachment doc, @config.thumbs.name, @config.thumbs.type, results[1], (err, doc)->
            console.log doc
            done err, new_docs.push doc
    , (err)->
      callback err, new_docs


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
