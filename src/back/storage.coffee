# A thin wrapper around PouchDB

PouchDB = require 'pouchdb'
path = require 'path'

class Storage
  constructor: (db_path)->
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

  add_attachment: (doc, name, type, buffer)->
    doc._attachments ?= {}
    doc._attachments[name] =
      content_type: type
      data: buffer
    return doc

  get_thumb: (doc, name, callback)->
    @db.getAttachment doc.id, name, (err, buffer)->
      callback err, buffer


module.exports = Storage
