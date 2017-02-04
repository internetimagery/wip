# Testing the utility functions
expect = require 'expect.js'
utility = require "../src/js/utility"


describe "format(<string>, <object>)", ->
  it "Should capture and replace {TAGNAME} brackets.", ->
    expect utility.format "one/{TAG}/three", {tag: "two"}
    .to.be "one/two/three"
  it "Should recognise upper and lowercase tag names.", ->
    expect utility.format "one {Tag}/three", {tag: "two"}
    .to.be "one two/three"
  it "Should only capture closing brackets.", ->
    expect utility.format "one {{TAG} three", {tag: "two"}
    .to.be "one {two three"
  it "Should skip backslashed brackets (escaped)", ->
    expect utility.format "\{one} {TAG} three", {tag: "two"}
    .to.be "{one} two three"
