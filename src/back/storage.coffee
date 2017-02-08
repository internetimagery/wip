# A thin wrapper around PouchDB

PouchDB = require 'pouchdb'
path = require 'path'
fs = require 'fs'

class Storage
  constructor: (db_path)->
    @thumb = "thumb.jpeg"
    @db = new PouchDB db_path,
      # auto_compaction: true # Turn off auto_compation if slow

  put: (doc, callback)->
    doc._id = doc.id
    @db.post doc, (err, result)->
      return callback err if err
      doc._id = result.id
      doc._rev = result.rev
      callback null, doc

  del: (doc, callback)->
    @db.remove doc, (err)->
      callback err

  get: (id, callback)->
    @db.get id, (err, doc)->
      callback err, doc

  get_all: (callback)->
    @db.allDocs (err, docs)->
      return callback err if err
      callback null, docs.rows

  add_thumb: (doc, thumb, callback)->
    return callback new Error "Thumb must be a jpeg" if ".jpeg" != path.extname thumb
    fs.readFile thumb, (err, buffer)=>
      return callback err if err
      doc._attachments ?= {}
      doc._attachments[@thumb] =
        content_type: "image/jpeg"
        data: buffer
      @put doc, callback

  get_thumb: (doc, callback)->
    @db.getAttachment doc.id, @thumb, (err, buffer)->
      callback err, buffer


module.exports = Storage
