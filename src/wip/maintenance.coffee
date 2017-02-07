# Tools to maintain and repair the repo

utility = require "../back/utility"

# Date metadata:
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
months = ["january","february","march","april","may","june","july","august","september","october","november","december"]

# Rebuild time tags if some are missing
build_time = (metadata)->
  date = new Date()
  for k, v of metadata
    switch k
      when "yyyy" then date.setFullYear v
      when "yy"
        if not metadata.yyyy
          date.setFullYear if parseInt(v) > 70 then "19#{v}" else "20#{v}"
      when "mm" then date.setMonth parseInt(v) - 1
      when "mmmm"
        if not metadata.mm
          i = months.indexOf v
          throw new Error "invalid \"MMMM\" tag value: #{v}" if i == -1
          date.setMonth i
      when "dd" then date.setDate v
  for k, v of date_tag
    metadata[k] = v(date)
  return metadata

# Move paths to a new location
# From A to B
migrate_paths = (cwdA, formatA, cwdB, formatB, paths, callback)->
  for p in paths
    metadata = build_time utility.deconstruct_path formatA, p
    new_p = utility.build_path formatB, metadata
    # Rebuild time stuff

    console.log p
    console.log new_p









test_formatA = "{YYYY}/{YY}-{MM}-{DD} {EVENT}/{YY}-{MM}-{DD} {EVENT}_{NUM}[{TAGS}]{EXT}"
test_paths = [
  "2017/17-02-01 Something/17-02-01 Something_001[tag also].jpeg"
  "2017/17-04-03 Something/17-04-03 Something_002[].jpeg"
]
test_formatB = "{YY}/{MMMM}/{EVENT}/{NUM}{EXT}"
migrate_paths "/", test_formatA, "/", test_formatB, test_paths, (err)->
