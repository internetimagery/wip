# Storage

path = require 'path'
temp = require 'temp'
expect = require 'expect.js'
DB = require "../src/back/storage"

tempfile = temp.mkdirSync {dir: path.join __dirname, "temp"}
STORE = new DB tempfile

doc =
  id: "test"
  path: "/here/there"
  hash: "abc"
  thumb: "/here/there/thumb"

describe "storage.put(<doc>, <callback>)", ->
  it "Should succeed in adding a document", (done)->
    STORE.put doc, (err, data)->
      return done err if err
      doc = data
      done()
describe "storage.get(<doc>, <callback>)", ->
  it "Should retrieve data.", (done)->
    STORE.get doc.id, (err, data)->
      try
        expect data.path
        .to.be doc.path
      catch err
      finally
        done err
describe "storage.del(<doc>, <callback>)", ->
  it "Should delete data.", (done)->
    STORE.del doc, (err)->
      done err
