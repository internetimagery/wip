# Testing the Repository!

expect = require 'expect.js'
path = require 'path'
temp = require 'temp'
fs = require 'fs'
Repo = require "../src/back/repo"

TEMP = temp.path {dir: path.join __dirname, "temp"}
REPO = null

describe "new Repo(<path>)", ->
  it "Should create a repository.", ->
    REPO = new Repo(TEMP)
    expect fs.existsSync TEMP
    .to.be.ok()

describe "repo.add(<images>)", ->
  @.timeout 5000 # Bit of extra wait time
  it "Should add images to the stash, attaining metadata etc", ->
    img = path.join __dirname, "test_data", "img_a.jpg"
    REPO.add img
    .then (docs)->
      expect docs
      .to.have.length 1
      expect docs[0]
      .to.have.property "hash"

describe "repo.list(<view>)", ->
  it "Should list files based on view", ->
    REPO.list "hash"
    .then (docs)->
      console.log docs

describe "repo.update(<doc>)", ->
  it "Should update data in db"

describe "repo.commit(<message>)", ->
  it "Should add files from stash to repo"

describe "repo.delete(<doc>)", ->
  it "Should remove a document from the repo"

describe "repo.read(<id>/<doc>)", ->
  it "Should read information from an id"
  it "Should also accept a document with an _id"

describe "repo.thumb(<id>/<doc>)", ->
  it "Should get thumbnail data to display from id"
  it "Should also accept a doc file"

describe "repo.config()", ->
  it "Should load up a config on the repo"
  it "Should use defaults if config doesn't exist"
