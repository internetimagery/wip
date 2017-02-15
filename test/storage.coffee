# Storage

fs = require '../src/back/fs'
path = require 'path'
temp = require 'temp'
expect = require 'expect.js'
Promise = require 'promise'
DB = require "../src/back/storage"

tempfile = temp.mkdirSync {dir: path.join __dirname, "temp"}
test_img = path.join __dirname, "test_data", "img_a.jpg"
STORE = new DB tempfile


describe "storage.put(<doc>, <callback>)", ->
  it "Should succeed in adding a document", ->
    STORE.put {_id: "image", path: "/here/there"}
    .then (doc)->
      expect doc
      .to.have.property "_rev"

describe "storage.get(<doc>, <callback>)", ->
  it "Should retrieve data.", ->
    STORE.get "image"
    .then (doc)->
      expect doc
      .to.have.property "path"

describe "storage.put_attachment(<doc>, <name>, <type>, <data>, <callback>)", ->
  it "Should save data to a doc", ->
    Promise.all [
      fs.readFile test_img
      STORE.get "image"
      ]
    .then (results)->
      STORE.put_attachment results[1], "img_a.jpg", "image/jpeg", results[0]
    .then (doc)->
      expect doc
      .to.have.property "_attachments"

describe "storage.get_attachment(<doc>, <name>, <callback>)", ->
  it "Should retrive data from attachment", ->
    STORE.get_attachment {_id: "image"}, "img_a.jpg"
    .then (buffer)->
      expect buffer.length
      .to.be.above 0

  it "Should fail to retrieve if attachment doesn't exist", ->
    STORE.get_attachment {_id: "image"}, "img_b.jpg"
    .then -> throw new Error "Missing attachment did not throw an error."
    .catch ->

describe "storage.del(<doc>, <callback>)", ->
  it "Should delete data.", ->
    STORE.get "image"
    .then (doc)->
      STORE.del doc
    .catch (err)-> throw err
    .then ->
      STORE.get "image"
    .then (doc)->
      throw new Error "File still exists in database."
    .catch ->

describe "storage.query(<name>, <function>)", ->
  it "Should run queries", ->
    STORE.put {_id: "test", data:"information", thing:"stuff"}
    .then ->
      STORE.put {_id: "test2", data:"more"}
    .then ->
      STORE.query "thing", (doc)-> emit doc.thing if doc.thing?
    .then (docs)->
      expect docs.length
      .to.be 1
      expect docs[0].key
      .to.be "stuff"
