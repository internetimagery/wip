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
  it "Should get a thumbnail from an image", (done)->
    img = path.join TEST_DATA, "img_a.jpg"
    thumb = path.join TEMP_DIR, "thumb1.jpg"
    ffmpeg.get_thumb img, thumb, 500, 500, (err)->
      done err
  it "Should get a thumbnail from a video", (done)->
    vid = path.join TEST_DATA, "video.mp4"
    thumb = path.join TEMP_DIR, "thumb2.jpg"
    ffmpeg.get_thumb vid, thumb, 500, 500, (err)->
      done err
