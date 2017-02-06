# Image manipulation

jimp = require 'jimp'
uString = require 'underscore.string'

imgA = "D:/Documents/GitHub/wip/test/test_data/img_a.jpg"
imgB = "D:/Documents/GitHub/wip/test/test_data/img_b.jpg"


h1 = "dwCgyOocg39"
h2 = "9h00000804o"

# console.log jimp.distance imgA, imgB
console.log uString.levenshtein h1, h1
