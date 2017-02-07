# Testing the utility functions
expect = require 'expect.js'
utility = require "../src/back/utility"

describe "utility.reg_escape(<string>)", ->
  it "Should escape nasty regex characters.", ->
    expect utility.reg_escape "carrat ^ here"
    .to.be "carrat \\^ here"

describe "utility.build_path(<string>, <object>)", ->
  it "Should replace tagnames with provided names.", ->
    expect utility.build_path "one/{four}/three", {four:"two"}
    .to.be "one/two/three"
  it "Should capture and replace all tags.", ->
    expect utility.build_path "{TAG1}/{TAG2}/three", {tag1: "one", tag2: "two"}
    .to.be "one/two/three"
  it "Should recognise upper and lowercase tag names.", ->
    expect utility.build_path "one {Tag}/three", {tag: "two"}
    .to.be "one two/three"
  it "Should only capture closing brackets.", ->
    expect utility.build_path "one {{TAG} three", {tag: "two"}
    .to.be "one {two three"
  # it "Should skip backslashed brackets (escaped)", ->
  #   expect utility.build_path "\{one} {TAG} three", {tag: "two"}
  #   .to.be "{one} two three"
  it "Should ignore if captured tags are not in <object>", ->
    expect utility.build_path "{GONE}", {}
    .to.be "{GONE}"
  it "Should fail if tag names are not valid.", ->
    expect utility.build_path "{no spaces}", {no:"not",spaces:"here"}
    .to.be "{no spaces}"
    expect utility.build_path "{letters(only)}", {letters:"not",only:"here"}
    .to.be "{letters(only)}"
    expect utility.build_path "{underscore_ok}", {underscore_ok:"good"}
    .to.be "good"

describe "utility.deconstruct_path(<string>, <string>)", ->
  it "Should pull out metadata from a path", ->
    expect utility.deconstruct_path "one/{two}/three", "one/four/three"
    .to.eql {two:"four"}
