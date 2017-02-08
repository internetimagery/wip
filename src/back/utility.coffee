# Some utility functionality

# Built in metadata:
# YYYY = Year, 2017
# MMMM = Month, "February"
# YY = Year, 17
# MM = Month, 02
# DD = Day, 01
date_tag = {
    yyyy: (x)-> x.getFullYear()
    mmmm: (x)-> months[x.getMonth()]
    yy: (x)-> x.getFullYear().toString()[2..]
    mm: (x)-> x.getMonth() + 1
    dd: (x)-> x.getDate()
}
months = ["January","February","March","April","May","June","July","August","September","October","November","December"]

# Escape regex string [https://stackoverflow.com/questions/2593637/how-to-escape-regular-expression-in-javascript#2593661]
reg_escape = (str)-> (str + "").replace /[.?*+^$[\]\\(){}|-]/g, "\\$&"

# Extract tags from a date object
extract_date = (date)->
  tags = {}
  for k, v of date_tag
    tags[k] = v(date)
  return tags

# Scan for tags {TAGS} within a path <string>
scan_tags = (src)->
  reg = /\{(\w+)\}/g
  t = []
  while match = reg.exec src
    reg.lastIndex = match.index + 1
    t.push {
      tag: match[1].toLowerCase()
      pos: match.index
      raw: match[0]
    }
  return t

# Build a path given a data, metadata and a format
build_path = (format, metadata={})->
  path = format
  for tag in scan_tags format
    path = path.replace tag.raw, if metadata[tag.tag]? then metadata[tag.tag] else ""
  return path

# Pull metadata back out of a formated path
deconstruct_path = (format, path)->
  metadata = {}
  tags = (t for t in scan_tags format)
  new_reg = reg_escape format
            .replace /\\\{\w+\\\}/g, "(.*)"
  vals = new RegExp(new_reg).exec(path)
  throw new Error "Path does not match format: #{format} :: #{path}" if not vals?
  for val, i in vals[1 ..]
    if not val.startsWith("{") and not val.endsWith("}")
      metadata[tags[i].tag] = val
  return metadata

# Get a simple unique id.
global.unique_id ?= 0
unique_id = ->
  id = Date.now()
  while (id += 1) <= global.unique_id
    continue
  global.unique_id = id


module.exports = {
  extract_date: extract_date
  build_path: build_path
  deconstruct_path: deconstruct_path
  reg_escape: reg_escape
  unique_id: unique_id
}
