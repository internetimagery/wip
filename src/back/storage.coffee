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
  constructor: (db_path)->
    @db = new PouchDB db_path, {auto_compaction: true} # Turn off auto_compation if slow

  # Validation and ID given on initial add.
  put: (data, callback)->
    for k, v of DOCUMENT_FORMAT
      return callback new Error "Invalid data: #{data}" if not v(data[k])
    data._id = data.path
    @db.put data, (err, result)->
      return callback err if err
      data._rev = result.rev
      callback null, data
    return

  # Put data in without any checks
  put_force: (data, callback)->
    @db.post data, (err, result)->
      return callback err if err
      data._rev = result.rev
      callback null, data
    return

  del: (data, callback)->
    @db.remove data, (err)->
      callback err
    return

  get: (id, callback)->
    @db.get id, callback
    return

  get_all: (callback)->
    @db.allDocs (err, docs)->
      return callback err if err
      callback null, docs.rows
    return

module.exports.Metadata = Metadata
