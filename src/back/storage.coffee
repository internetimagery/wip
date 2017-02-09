# A thin wrapper around PouchDB

PouchDB = require 'pouchdb'

class Storage
  constructor: (db_path)->
    @db = new PouchDB db_path,
      # auto_compaction: true # Turn off auto_compation if slow

  put: (doc, callback)->
    doc._id ?= doc.id
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

  add_attachment: (doc, name, type, buffer, callback)->
    doc._id ?= doc.id
    @db.putAttachment doc._id, name, doc._rev, buffer, type, (err, result)=>
      return callback err if err
      @get doc._id, callback

  get_thumb: (doc, name, callback)->
    @db.getAttachment doc.id, name, (err, buffer)->
      callback err, buffer


module.exports = Storage
