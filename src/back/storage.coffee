# A thin wrapper around PouchDB

PouchDB = require 'pouchdb'

e = (cb1, cb2)-> return (err, args...)-> if err then cb1 err else cb2 args...

class Storage
  constructor: (db_path)->
    @db = new PouchDB db_path,
      # auto_compaction: true # Turn off auto_compation if slow

  put: (doc, cb)->
    @db.post doc, e cb, (result)->
      doc._rev = result.rev
      cb null, doc
    return

  del: (doc, cb)->
    @db.remove doc, (err)->
      cb err
    return

  get: (id, cb)->
    @db.get id, (err, doc)->
      cb err, doc
    return

  get_all: (cb)->
    @db.allDocs e cb, (docs)->
      cb null, docs.rows
    return

  add_attachment: (doc, name, type, buffer, cb)->
    @db.putAttachment doc._id, name, doc._rev, buffer, type, e cb, (result)=>
      @get doc._id, cb
    return

  get_attachment: (doc, name, cb)->
    @db.getAttachment doc._id, name, (err, buffer)->
      cb err, buffer
    return


module.exports = Storage
