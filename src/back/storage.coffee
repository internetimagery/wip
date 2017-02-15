# A thin wrapper around PouchDB

PouchDB = require 'pouchdb'

class Storage
  constructor: (db_path)->
    @db = new PouchDB db_path,
      # auto_compaction: true # Compress database on each entry

  put: (doc)->
    @db.post doc
    .catch (err)=>
      throw new Error err if err.name != "conflict"
      @db.get doc._id
      .then (n_doc)=>
        doc._rev = n_doc._rev
        @db.put doc
    .then (result)->
      doc._rev = result.rev
      doc

  del: (doc)-> @db.remove doc

  get: (id)-> @db.get id

  get_all: ->
    @db.allDocs().then (docs)->
      docs.rows

  put_attachment: (doc, name, type, buffer)->
    @db.putAttachment doc._id, name, doc._rev, buffer, type
    .then (result)=>
      @db.get doc._id

  get_attachment: (doc, name)-> @db.getAttachment doc._id, name

  query: (name, func)->
    id = "photos/#{name}"
    @db.query id
    .catch (err)=>
      throw new Error err if err.name != "not_found"
      doc = {
        _id: "_design/photos"
        views: {}
        }
      doc.views[name] = {map: func.toString()}
      @put doc
      .then =>
        @db.query id
    .then (docs)->
      docs.rows


module.exports = Storage
