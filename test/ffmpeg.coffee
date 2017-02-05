# FFmpeg stuff
expect = require 'expect.js'
temp = require 'temp'
ffmpeg = require '../src/back/ffmpeg'
path = require 'path'

p = "D:/Pictures/Random Drawings/DSC_05712.jpg"

# Automatically delete temporary files
temp.track()

TEST_IMG = path.join __dirname, "test_images"
TEMP_DIR = temp.mkdirSync {dir: TEST_IMG}

# Some test images
# HAS_EXIF = path.join __dirname, "test_images", "has_exif.jpg"
METADATA = path.join TEST_IMG, "metadata.mp4"

describe "get_metadata(<file>, <callback>)", ->
  it "Should retrieve an object of key/value pairs for metadata", (done)->
    ffmpeg.get_metadata METADATA, (err, data)->
      return done err if err
      try
        expect data
        .to.be.an "object"
      catch err
      finally
        done err

describe "get_thumb(<file>, <width>, <height>)", ->
  it "Should get a thumbnail from an image", ->
    expect "thumb"
  it "Should get a thumbnail from a video", ->
    expect "thumb"
  it "Should fail on a non-media file", ->
    expect "error"
