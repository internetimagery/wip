# Promise wrapper for fs-extra (which is a fs wrapper itself! Oh meta)

fs = require 'fs-extra'
Promise = require 'promise'

module.exports = {}
for k, v of fs
  if "function" == typeof v and k.endsWith "Sync"
    module.exports[k] = Promise.denodeify v
  else
    module.exports[k] = v
