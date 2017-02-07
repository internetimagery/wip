# Generate paths given metadata

# Built in metadata:
# YYYY = Year, 2017
# MMMM = Month, "February"
# YY = Year, 17
# MM = Month, 02
# DD = Day, 01
date_tag = {
    yyyy: (x)-> x.getFullYear()
    mmmm: (x)-> months[x.getMonth()]
    yy: (x)-> x.getFullYear()[2..]
    mm: (x)-> x.getMonth() + 1
    dd: (x)-> x.getDate()
}

months = ["January","February","March","April","May","June","July","August","September","October","November","December"]

# Escape regex string [https://stackoverflow.com/questions/2593637/how-to-escape-regular-expression-in-javascript#2593661]
RegExp.quote = (str)-> (str + "").replace /[.?*+^$[\]\\(){}|-]/g, "\\$&"

# Scan for tags within a path <string>
scan = (src)->
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
build = (format, date=new Date(), metadata={})->
  # Pull out tags and replace with anything we have
  path = format
  for tag in scan format
    if date_tag[tag.tag]?
      path = path.replace tag.raw, date_tag[tag.tag](date)
    else if metadata[tag.tag]?
      path = path.replace tag.raw, metadata[tag.tag]
  return path

# Pull metadata back out of a formated path
deconstruct = (format, path)->
  metadata = {}
  tags = (t for t in scan format)
  new_reg = RegExp.quote format
            .replace /\\\{\w+\\\}/g, "(.+)"
  for val, i in new RegExp(new_reg).exec(path)[1 ..]
    if not val.startsWith("{") and not val.endsWith("}")
      metadata[tags[i].tag] = val
  return metadata


# test = [
#   "{YYYY}^/{MM}/{three}"
#   "something {MMMM}"
#   "{not a tag}"
#   "no tag"
#   "tag {missing} but {three} and {also_gone}"
# ]
#
# paths = (build t, new Date(), {three:"stuff"} for t in test)
#
#
# for p, i in paths
#   console.log p, deconstruct test[i], p
