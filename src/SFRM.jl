module SFRM

using FileIO
using OffsetArrays: Origin
using ImageMetadata
using Dates
using Printf

const BLOCK_SIZE = 512
const BLOCKS_MIN = 5
const LINE_LEN = 80
const KEY_LEN = 8
const DATA_ALIGNMENT = 16

include("utils.jl")
include("defines.jl")
include("parse.jl")
include("compress.jl")
include("load.jl")

end # module SFRM
