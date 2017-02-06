# Store metadata

PouchDB = require 'pouchdb'

# Validate our document format!
DOCUMENT_FORMAT = {
  thumb: (x)-> x? # Path to thumbnail
  hash: (x)-> x? # Image hash
  path: (x)-> x? # Path to image
}

# Add and remove date from the storage database
class Metadata
  @db = null
  constructor: (db_path)->
    @db = new PouchDB db_path, {auto_compaction: true} # Turn off auto_compation if slow

  # Validation and ID given on initial add.
  add: (data, callback)->
    for k, v of DOCUMENT_FORMAT
      return callback new Error "Invalid data: #{data}" if not v(data[k])
    # data._id = new Date().toISOString()
    data._id = data.path
    @db.post data, (err, result)->
      return callback err if err
      data._id = result.id
      data._rev = result.rev
      callback null, data

  # edit: (data, callback)->
  #   @db.put data, (err, result)->
  #     return callback err if err
  #     data._rev = result.rev
  #     callback null, data

  del: (data, callback)->
    @db.remove data, (err)->
      callback err

  get: (id, callback)->
    @db.get id, callback

  get_all: (callback)->
    @db.allDocs (err, docs)->
      return callback err if err
      callback null, docs.rows
