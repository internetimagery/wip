# Storage

fs = require 'fs'
path = require 'path'
temp = require 'temp'
expect = require 'expect.js'
DB = require "../src/back/storage"

tempfile = temp.mkdirSync {dir: path.join __dirname, "temp"}
test_img = path.join __dirname, "test_data", "img_a.jpg"
STORE = new DB tempfile

describe "storage.put(<doc>, <callback>)", ->
  it "Should succeed in adding a document", (done)->
    STORE.put {_id: "image", path: "/here/there"}
    .then (doc)->
      expect doc
      .to.have.property "_rev"
    .catch done

describe "storage.get(<doc>, <callback>)", ->
  it "Should retrieve data.", (done)->
    STORE.get "image"
    .then (doc)->
      expect doc
      .to.have.property "path"
    .catch done

describe "storage.add_attachment(<doc>, <name>, <type>, <data>, <callback>)", ->
  it "Should save data to a doc", (done)->
    fs.readFile test_img
    .then (buffer)->
      STORE.get "image"
    .then (doc)->
      STORE.add_attachment doc, "img_a.jpg", "image/jpeg", buffer
    .then (doc)->
      expect doc
      .to.have.property "_attachments"
    .catch done

describe "storage.get_attachment(<doc>, <name>, <callback>)", ->
  it "Should retrive data from attachment", (done)->
    STORE.get_attachment {_id: "image"}, "img_a.jpg"
    .then (buffer)->
      expect buffer.length
      .to.be.above 0
    .catch done

  it "Should fail to retrieve if attachment doesn't exist", (done)->
    STORE.get_attachment {_id: "image"}, "img_b.jpg"
    .then -> done new Error "Missing attachment did not throw an error."
    .catch -> done()

describe "storage.del(<doc>, <callback>)", ->
  it "Should delete data.", (done)->
    STORE.get "image"
    .then (doc)->
      STORE.del doc
    .catch done
    .then ->
      STORE.get "image"
    .then (doc)->
      done new Error "File still exists in database."
    .catch (err)-> done()
