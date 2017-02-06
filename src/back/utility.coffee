# Some utility functionality

# Format a string, taking {TAGNAME} and replacing with an object {tagname: "text"}
module.exports.format = (src, replace)->
  # tags = src.match /\{\w+?\}/g
  reg = /\{(\w+)\}/g
  src2 = src
  while tag = reg.exec src
    text = replace[tag[1].toLowerCase()]
    if text?
      src2 = src2.replace tag[0], text
    reg.lastIndex = tag.index + 1
  return src2
