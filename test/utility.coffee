# Testing the utility functions
expect = require 'expect.js'
utility = require "../src/back/utility"


describe "format(<string>, <object>)", ->
  it "Should capture and replace {TAGNAME} brackets.", ->
    expect utility.format "one/{TAG}/three", {tag: "two"}
    .to.be "one/two/three"
  it "Should capture and replace all tags.", ->
    expect utility.format "{TAG1}/{TAG2}/three", {tag1: "one", tag2: "two"}
    .to.be "one/two/three"
  it "Should recognise upper and lowercase tag names.", ->
    expect utility.format "one {Tag}/three", {tag: "two"}
    .to.be "one two/three"
  it "Should only capture closing brackets.", ->
    expect utility.format "one {{TAG} three", {tag: "two"}
    .to.be "one {two three"
  # it "Should skip backslashed brackets (escaped)", ->
  #   expect utility.format "\{one} {TAG} three", {tag: "two"}
  #   .to.be "{one} two three"
  it "Should fail if captured tags are not in <object>", ->
    expect utility.format "{GONE}", {}
    .to.be "{GONE}"
  it "Should fail if tag names are not valid.", ->
    expect utility.format "{no spaces}", {no:"not",spaces:"here"}
    .to.be "{no spaces}"
    expect utility.format "{letters(only)}", {letters:"not",only:"here"}
    .to.be "{letters(only)}"
    expect utility.format "{underscore_ok}", {underscore_ok:"good"}
    .to.be "good"

# describe "compare_image_hash(<hash1>, <hash2>)", ->
#   it "Should see two of the same image as the same.", ->
#     expect compare_image_hash hash1, hash2
#     .to.be true
#   it "Should see two of the same image different sizes as the same.", ->
#     expect compare_image_hash hash1, hash2
#     .to.be true
#   it "Should see two different images as the different.", ->
#     expect compare_image_hash hash1, hash2
#     .to.be false
