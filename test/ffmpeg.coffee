# FFmpeg stuff
str = require 'underscore.string'
expect = require 'expect.js'
temp = require 'temp'
ffmpeg = require '../src/back/ffmpeg'
path = require 'path'
fs = require 'fs'

# Automatically delete temporary files
# temp.track()

TEST_DATA = path.join __dirname, "test_data"
TEMP_DIR = temp.mkdirSync {dir: __dirname + "/temp"}


describe "ffmpeg.metadata(<file>, <callback>)", ->
  VIDEO = path.join TEST_DATA, "video.mp4"
  it "Should retrieve an object of key/value pairs for metadata", (done)->
    ffmpeg.metadata VIDEO
    .then (data)->
      expect data
      .to.be.an "object"
      done()
    .catch done

describe "ffmpeg.thumb(<src>, <width>, <height>, <callback>)", ->
  it "Should get thumbnail data from an image", (done)->
    img = path.join TEST_DATA, "img_a.jpg"
    ffmpeg.thumb img, 500, 500
    .then (buffer)->
      expect buffer
      .not.to.be.empty()
    .catch done

  it "Should get a thumbnail from a video", (done)->
    vid = path.join TEST_DATA, "video.mp4"
    ffmpeg.thumb vid, 500, 500
    .then (buffer)->
      expect buffer
      .not.to.be.empty()
    .catch done

describe "ffmpeg.hash(<image>, <callback>)", ->
  imga = path.join TEST_DATA, "img_a.jpg"
  imgb = path.join TEST_DATA, "img_b.jpg"
  it "Should match two of the same image", (done)->
    ffmpeg.hash imga
    .then (hasha)->
      ffmpeg.hash imga
      .then (hashb)->
        expect str.levenshtein hasha, hashb
        .to.be.within 0, 0.01
      .catch done
    .catch done

  it "Should fail to match two of the same image.", (done)->
    ffmpeg.hash imga
    .then (hasha)->
      ffmpeg.hash imgb
      .then (hashb)->
        expect str.levenshtein hasha, hashb
        .to.be.above 5
      .catch done
    .catch done
