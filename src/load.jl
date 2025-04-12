function read_header_blocks(io::IO, nblocks::Integer)
    header = Dict{String,Any}()
    blocks = read(io, BLOCK_SIZE * nblocks)
    for line in eachcol(reshape(blocks, LINE_LEN, :))
        key, value = match(r"(\S+)\s*:(.*)", String(line))
        header[key] = haskey(header, key) ? header[key] * value : value
    end
    header
end

function read_image(io::IO, header::AbstractDict)
    format = header["FORMAT"]
    rows = header["NROWS"][1]
    cols = header["NCOLS"][1]
    npixelb = header["NPIXELB"]
    noverflow = header["NOVERFL"]
    compressed = if format == 86
        BrukerImage86(
            read_aligned_array(io, unsigned_integer(npixelb), rows * cols),
            String(read_aligned_array(io, UInt8, 16 * noverflow)),
        )
    elseif format == 100
        BrukerImage100(
            read_aligned_array(io, unsigned_integer(npixelb[1]), rows * cols),
            read_aligned_array(io, signed_integer(npixelb[2]), noverflow[1]),
            read_aligned_array(io, UInt16, noverflow[2]),
            read_aligned_array(io, Int32, noverflow[3]),
            header["NEXP"][3],
        )
    else
        error("Unknown sfrm format: $(format)")
    end
    image = decompress(compressed)
    if haskey(header, "LINEAR")
        slope, offset = header["LINEAR"]
        if slope != 1 || offset != 0
            image = image * slope + offset
        end
    end
    Origin(0)(transpose(reverse!(reshape(image, cols, rows), dims = 2)))
end

function load(io::IO)
    header = read_header_blocks(io, BLOCKS_MIN)
    hdrblks = parse_line("HDRBLKS", header["HDRBLKS"])
    header_rem = read_header_blocks(io, hdrblks - BLOCKS_MIN)
    mergewith!(*, header, header_rem)
    for (key, value) in header
        header[key] = parse_line(key, value)
    end
    image = read_image(io, header)
    SiemensFrame(image, header)
end

load(path::AbstractString) = open(load, path, "r")

function load(f::File{format"SFRM"})
    open(f, "r") do s
        load(s.io)
    end
end
