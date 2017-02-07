# Some utility functionality

# Escape regex string [https://stackoverflow.com/questions/2593637/how-to-escape-regular-expression-in-javascript#2593661]
reg_escape = (str)-> (str + "").replace /[.?*+^$[\]\\(){}|-]/g, "\\$&"

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
    path = path.replace tag.raw, metadata[tag.tag] if metadata[tag.tag]?
  return path

# Pull metadata back out of a formated path
deconstruct_path = (format, path)->
  metadata = {}
  tags = (t for t in scan_tags format)
  new_reg = reg_escape format
            .replace /\\\{\w+\\\}/g, "(.+)"
  for val, i in new RegExp(new_reg).exec(path)[1 ..]
    if not val.startsWith("{") and not val.endsWith("}")
      metadata[tags[i].tag] = val
  return metadata

module.exports = {
  build_path: build_path
  deconstruct_path: deconstruct_path
  reg_escape: reg_escape
}
