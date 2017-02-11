# FFmpeg stuff
str = require 'underscore.string'
expect = require 'expect.js'
ffmpeg = require '../src/back/ffmpeg'
path = require 'path'
fs = require 'fs'
Promise = require 'promise'

TEST_DATA = path.join __dirname, "test_data"

describe "ffmpeg.metadata(<file>, <callback>)", ->
  VIDEO = path.join TEST_DATA, "video.mp4"
  it "Should retrieve an object of key/value pairs for metadata", ->
    ffmpeg.metadata VIDEO
    .then (data)->
      expect data
      .to.be.an "object"

describe "ffmpeg.thumb(<src>, <width>, <height>, <callback>)", ->
  it "Should get thumbnail data from an image", ->
    img = path.join TEST_DATA, "img_a.jpg"
    ffmpeg.thumb img, 500, 500
    .then (buffer)->
      expect buffer
      .not.to.be.empty()

  it "Should get a thumbnail from a video", ->
    vid = path.join TEST_DATA, "video.mp4"
    ffmpeg.thumb vid, 500, 500
    .then (buffer)->
      expect buffer
      .not.to.be.empty()

describe "ffmpeg.hash(<image>, <callback>)", ->
  imga = path.join TEST_DATA, "img_a.jpg"
  imgb = path.join TEST_DATA, "img_b.jpg"
  it "Should match two of the same image", ->
    Promise.all [
      ffmpeg.hash imga
      ffmpeg.hash imga
      ]
    .then (hash)->
      expect str.levenshtein hash[0], hash[1]
      .to.be.within 0, 0.01

  it "Should fail to match two of the same image.", ->
    Promise.all [
      ffmpeg.hash imga
      ffmpeg.hash imgb
      ]
    .then (hash)->
      expect str.levenshtein hash[0], hash[1]
      .to.be.above 5
