# A thin wrapper around PouchDB

PouchDB = require 'pouchdb'

class Storage
  constructor: (db_path)->
    @db = new PouchDB db_path,
      # auto_compaction: true # Turn off auto_compation if slow

  put: (doc)->
    @db.post doc
    .then (result)->
      doc._rev = result.rev
      doc

  del: (doc)-> @db.remove doc

  get: (id)-> @db.get id

  get_all: (cb)->
    @db.allDocs().then (docs)->
      docs.rows

  put_attachment: (doc, name, type, buffer)->
    @db.putAttachment doc._id, name, doc._rev, buffer, type
    .then (result)=>
      @get doc._id

  get_attachment: (doc, name, cb)-> @db.getAttachment doc._id, name


module.exports = Storage
