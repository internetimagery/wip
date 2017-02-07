# Tools to maintain and repair the repo

# Extract information from existing paths to form new paths
# paths = list of filepaths that currently exist
# format_old = the old format that created the paths in the first place
# format_new = what we'll use to rebuild the paths
module.exports.migrate = (paths, format_old, format_new, callback)->

  # TODO: collect information parsing out original tags from paths
  # TODO: work out additional information (ie YY=17 is also YYYY=2017)
  # TODO: recreate new paths based on the information
  # TODO: send back the new paths

  console.log "here"
