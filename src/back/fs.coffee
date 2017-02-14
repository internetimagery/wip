# Promise wrapper for fs-extra (which is a fs wrapper itself! Oh meta)

fs = require 'fs-extra'
Promise = require 'promise'

module.exports = {}
for k, v of fs
  if "function" == typeof v and not k.endsWith "Sync"
    module.exports[k] = Promise.denodeify v
  else
    module.exports[k] = v

# Custom copy function
module.exports.copy = (src, dest)->
  new Promise (ok, fail)->
    fs.link src, dest, (err)->
      if err
        fs.copy src, dest, (err)->
          if err then fail err else ok()
