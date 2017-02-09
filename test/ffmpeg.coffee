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
    ffmpeg.metadata VIDEO, (err, data)->
      return done err if err
      try
        expect data
        .to.be.an "object"
      catch err
      finally
        done err

describe "ffmpeg.thumb(<src>, <width>, <height>, <callback>)", ->
  it "Should get thumbnail data from an image", (done)->
    img = path.join TEST_DATA, "img_a.jpg"
    ffmpeg.thumb img, 500, 500, (err, buffer)->
      done err if err
      try
        expect buffer
        .not.to.be.empty()
      catch err
      finally
        done err
  it "Should get a thumbnail from a video", (done)->
    vid = path.join TEST_DATA, "video.mp4"
    ffmpeg.thumb vid, 500, 500, (err, buffer)->
      done err if err
      try
        expect buffer
        .not.to.be.empty()
      catch err
      finally
        done err

describe "ffmpeg.hash(<image>, <callback>)", ->
  imga = path.join TEST_DATA, "img_a.jpg"
  imgb = path.join TEST_DATA, "img_b.jpg"
  it "Should match two of the same image", (done)->
    ffmpeg.hash imga, (err, hasha)->
      return done err if err
      ffmpeg.hash imga, (err, hashb)->
        return done err if err
        try
          expect str.levenshtein hasha, hashb
          .to.be.within 0, 0.01
        catch err
        finally
          done err
  it "Should fail to match two of the same image.", (done)->
    ffmpeg.hash imga, (err, hasha)->
      return done err if err
      ffmpeg.hash imgb, (err, hashb)->
        return done err if err
        try
          expect str.levenshtein hasha, hashb
          .to.be.above 5
        catch err
        finally
          done err
