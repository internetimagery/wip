# Some utility functionality

# Format a string, taking {TAGNAME} and replacing with an object {tagname: "text"}
format = /\{(.+?)\}/g
module.exports.format = (src, replace)->
  console.log format.exec src
# REFER TO
# https://stackoverflow.com/questions/30037699/javascript-regex-to-match-unless-preceded-by-backslash/30038104
