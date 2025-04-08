module SFRM

using FileIO
using OffsetArrays: Origin
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

mktemp() do fpath, _
    sfrm = SiemensFrame(
        Origin(0)(clamp.(rand(Int32, 1024, 768), 0, typemax(Int32))),
        "SCAN FRAME",
        basename(fpath),
        now(),
        600 * rand(),
        2pi * rand(4),
        "Mo",
        100 * rand(),
        10 * rand(),
        200 * rand(),
        2 + rand(Bool),
        2pi * rand(),
    )
    save(fpath, sfrm)
    load(fpath)
    Sys.iswindows() && GC.gc()
end

end # module SFRM
