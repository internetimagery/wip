# A thin wrapper around PouchDB

PouchDB = require 'pouchdb'

class Storage
  constructor: (db_path)->
    @db = new PouchDB db_path,
      # auto_compaction: true # Turn off auto_compation if slow

  put: (doc, callback)->
    @db.post doc, (err, result)->
      return callback err if err
      doc._rev = result.rev
      callback null, doc
    return

  del: (doc, callback)->
    @db.remove doc, (err)->
      callback err
    return

  get: (id, callback)->
    @db.get id, (err, doc)->
      callback err, doc
    return

  get_all: (callback)->
    @db.allDocs (err, docs)->
      return callback err if err
      callback null, docs.rows
    return

  add_attachment: (doc, name, type, buffer, callback)->
    @db.putAttachment doc._id, name, doc._rev, buffer, type, (err, result)=>
      return callback err if err
      @get doc._id, callback
    return

  get_attachment: (doc, name, callback)->
    @db.getAttachment doc._id, name, (err, buffer)->
      callback err, buffer
    return


module.exports = Storage
