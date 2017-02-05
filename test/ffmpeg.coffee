# FFmpeg stuff
expect = require 'expect.js'
temp = require 'temp'
ffmpeg = require '../src/back/ffmpeg'
path = require 'path'

# Automatically delete temporary files
temp.track()

TEST_DATA = path.join __dirname, "test_data"
TEMP_DIR = temp.mkdirSync {dir: TEST_DATA}


describe "get_metadata(<file>, <callback>)", ->
  VIDEO = path.join TEST_DATA, "video.mp4"
  it "Should retrieve an object of key/value pairs for metadata", (done)->
    ffmpeg.get_metadata VIDEO, (err, data)->
      return done err if err
      try
        expect data
        .to.be.an "object"
      catch err
      finally
        done err

describe "get_thumb(<src>, <dest>, <width>, <height>, <callback>)", ->
  VIDEO = path.join TEST_DATA, "video.mp4"
  it "Should get a thumbnail from an image", ->
    expect "thumb"
  it "Should get a thumbnail from a video", ->
    expect "thumb"
  it "Should fail on a non-media file", ->
    expect "error"
