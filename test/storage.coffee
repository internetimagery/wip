# Storage

path = require 'path'
temp = require 'temp'
expect = require 'expect.js'
store = require "../src/back/storage"

# temp.track()

describe "put(<doc>, <callback>)", ->
  tempfile = temp.mkdirSync {dir: path.join __dirname, "test_data"}
  STORE = new store.Metadata tempfile
  it "Should fail to add invalid data", (done)->
    STORE.put {one: "two"}, (err, data)->
      if err then done() else done new Error "Did not fail to insert data."
  it "Should succeed in adding valid data", (done)->
    valid =
      path: "/here/there"
      hash: "abc"
      thumb: "/here/there/thumb"
    STORE.put valid, (err, data)->
      if err then done err else done()
  it "Should retrieve data.", (done)->
    valid =
      path: "/here/where"
      hash: "abc"
      thumb: "/here/there/elsewhere"
    STORE.put valid, (err, data)->
      return done err if err
      STORE.get valid.path, (err, doc)->
        try
          expect doc.path
          .to.be valid.path
          expect doc.hash
          .to.be valid.hash
          expect doc.thumb
          .to.be valid.thumb
        catch err
        finally
          done err
  it "Should delete data.", (done)->
    valid =
      path: "/here/somewhere"
      hash: "abc"
      thumb: "/here/there/elsewhere"
    STORE.put valid, (err, data)->
      return done err if err
      STORE.del data, (err)->
        done err

# storage class
# add
# edit
# del
