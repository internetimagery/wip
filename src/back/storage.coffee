# A thin wrapper around PouchDB

PouchDB = require 'pouchdb'

class Storage
  constructor: (db_path)->
    @db = new PouchDB db_path,
      # auto_compaction: true # Compress database on each entry

  put: (doc)->
    @db.post doc
    .then (result)->
      # Return the doc with a new revision,
      # so it can be added right back in again
      doc._rev = result.rev
      doc

  del: (doc)-> @db.remove doc

  get: (id)-> @db.get id

  get_all: ->
    @db.allDocs().then (docs)->
      # Pretty sure all we need are rows
      docs.rows

  put_attachment: (doc, name, type, buffer)->
    @db.putAttachment doc._id, name, doc._rev, buffer, type
    .then (result)=>
      # Get all attachment info in our doc
      @get doc._id

  get_attachment: (doc, name)-> @db.getAttachment doc._id, name

  compile: (name, func)->
    doc = {
      _id: "_design/photos"
      views: {}
    }
    doc.views[name] = {map: func.toString()}
    @db.put doc

  query: (name)->
    name = "photos/#{name}" if "string" == typeof name
    @db.query name
    .then (docs)->
      docs.rows

module.exports = Storage
