# Testing config file!

expect = require 'expect.js'
path = require 'path'
fs = require 'fs'
temp = require 'temp'
config = require "../src/back/config"

TEMP = path.join __dirname, "temp"

describe "load(<file>, <callback>)", ->
  it "Should load an existing config file.", (done)->
    file = path.join(TEMP, "config.json")
    fs.writeFileSync file, JSON.stringify {data:"here"}
    config.load file, (err, data)->
      return done err if err
      try
        expect data.data
        .to.be "here"
      catch err
      finally
        done err
  it "Should load create a default file if none.", (done)->
    file = temp.path {dir: __dirname + "/temp"}
    config.load file, (err, data)->
      return done err if err
      try
        expect fs.existsSync file
        .to.be true
      catch err
      finally
        done err
