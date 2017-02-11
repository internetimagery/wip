# Testing the Repository!

expect = require 'expect.js'
path = require 'path'
temp = require 'temp'
fs = require 'fs'
Repo = require "../src/back/repo"

TEMP = temp.path {dir: path.join __dirname, "temp"}
REPO = new Repo("testing")

describe "repo.init(<path>, <callback>)", ->
  it "Should create a repository.", ->
    REPO.init TEMP
    .then ->
      expect fs.existsSync TEMP
      .to.be.ok()

describe "repo.get_doc(<image>, <date>, <event>, <tags>)", ->
  it "Should provide a document we can insert into the database", ->
    expect REPO.get_doc "/here/there/", new Date(), "nowhere", ["one", "two"]
    .to.have.property "_id"

describe "repo.add(<docs>, <callback>)", ->
  it "Should add a document to the repo, attaining metadata etc", ->
    img = path.join __dirname, "test_data", "img_a.jpg"
    doc = REPO.get_doc img, new Date(), "testing", ["test", "image"]
    REPO.add [doc]
    .then (docs)->
      expect docs
      .to.have.length 1
      expect docs[0]
      .to.have.property "hash"
