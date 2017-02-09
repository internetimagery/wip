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
    STORE.put {_id: "image", path: "/here/there"}, (err, doc)->
      return done err if err
      try
        expect doc
        .to.have.property "_rev"
      catch err
      finally
        done err
describe "storage.get(<doc>, <callback>)", ->
  it "Should retrieve data.", (done)->
    STORE.get "image", (err, doc)->
      return done err if err
      try
        expect doc
        .to.have.property "path"
      catch err
      finally
        done err
describe "storage.add_attachment(<doc>, <name>, <type>, <data>, <callback>)", ->
  it "Should save data to a doc", (done)->
    fs.readFile test_img, (err, buffer)->
      STORE.get "image", (err, doc)->
        return done err if err
        STORE.add_attachment doc, "img_a.jpg", "image/jpeg", buffer, (err, doc)->
          return done err if err
          try
            expect doc
            .to.have.property "_attachments"
          catch err
          finally
            done err
describe "storage.get_attachment(<doc>, <name>, <callback>)", ->
  it "Should retrive data from attachment", (done)->
    STORE.get_attachment {_id: "image"}, "img_a.jpg", (err, buffer)->
      return done err if err
      try
        expect buffer.length
        .to.be.above 0
      catch err
      finally
        done err
  it "Should fail to retrieve if attachment doesn't exist", (done)->
    STORE.get_attachment {_id: "image"}, "img_b.jpg", (err, buffer)->
      return done() if err
      done new Error "Missing attachment did not throw an error."
describe "storage.del(<doc>, <callback>)", ->
  it "Should delete data.", (done)->
    STORE.get "image", (err, doc)->
      return done err if err
      STORE.del doc, (err)->
        return done err if err
        STORE.get "image", (err, doc)->
          return done() if err
          done new Error "File still exists in database."
