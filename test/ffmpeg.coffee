# FFmpeg stuff
expect = require 'expect.js'

describe "get_metadata(<file>)", ->
  it "Should retrieve an object of key/value pairs for metadata", ->
    expect "something"
  it "Should retrieve an empty object for file without metadata", ->
    expect "nothing"

describe "get_hash(<file>)", ->
  it "Should get a hash from an image", ->
    expect "hash"
  it "Should fail on a non-media file", ->
    expect "error"

describe "get_thumb(<file>, <width>, <height>)", ->
  it "Should get a thumbnail from an image", ->
    expect "thumb"
  it "Should get a thumbnail from a video", ->
    expect "thumb"
  it "Should fail on a non-media file", ->
    expect "error"
