module SFRM

using FileIO
using Dates
using Printf

const BLOCK_SIZE = 512
const BLOCKS_MIN = 5
const LINE_LEN = 80
const DATA_ALIGNMENT = 16

include("utils.jl")
include("parse.jl")
include("compress.jl")
include("file.jl")
include("load.jl")
include("save.jl")

end # module SFRM
