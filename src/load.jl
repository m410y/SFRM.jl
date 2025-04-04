function read_line(io::IO)
    line = UInt8[]
    readbytes!(io, line, LINE_LEN)
    m = match(r"(\S+)\s*:(.*)", String(line))
    m.captures
end

function read_blocks(io::IO, blocks::Integer)
    lines = div(BLOCK_SIZE * blocks, LINE_LEN)
    header = HeaderParser()
    for _ in 1:lines
        key, value = read_line(io::IO)
        key = String(rstrip(key))
        header[key] = value
    end
    header
end

function read_image(io::IO, header::AbstractDict)
    format = header["FORMAT"]
    rows = header["NROWS"][1]
    cols = header["NCOLS"][1]
    compressed = if format == 86
        BrukerImage86(
            read_aligned_array(io, unsigned_integer(header["NPIXELB"]), rows * cols),
            String(read_aligned_array(io, UInt8, 16 * header["NOVERFL"]))
        )
    elseif format == 100
        BrukerImage100(
            read_aligned_array(io, unsigned_integer(header["NPIXELB"][1]), rows * cols),
            read_aligned_array(io, signed_integer(header["NPIXELB"][2]), header["NOVERFL"][1]),
            read_aligned_array(io, UInt16, header["NOVERFL"][2]),
            read_aligned_array(io, Int32, header["NOVERFL"][3]),
            header["NEXP"][3]
        )
    else
        error("Unknown sfrm format: $(format)")
    end
    image = decompress(compressed)
    if haskey(header, "LINEAR")
        slope = header["LINEAR"][1]
        offset = header["LINEAR"][2]
        if slope != 1 || offset != 0
            image = image * slope + offset
        end
    end
    Origin(0)(transpose(reverse(reshape(image, cols, rows), dims=2)))
end

function load(io::IO)
    header = read_blocks(io, BLOCKS_MIN)
    merge!(header, read_blocks(io, header["HDRBLKS"] - BLOCKS_MIN))
    img = read_image(io, header)
    ImageMeta(img,
        format = parsed["FORMAT"],
        type = parsed["TYPE"],
        ncounts = parsed["NCOUNTS"][1],
        maximum = parsed["MAXIMUM"],
        filename = parsed["FILENAM"],
        created = parsed["CREATED"],
        time = parsed["CUMULAT"],
        angles = parsed["ANGLES"],
        target = parsed["TARGET"],
        voltage = parsed["SOURCEK"],
        current = parsed["SOURCEM"],
        distance = 10 * parsed["DISTANC"][2],
        axis = parsed["AXIS"],
        increment = parsed["INCREME"],
        pixel = 5120 / parsed["NROWS"][1] / parsed["DETTYPE"][2],
        temperature = haskey(parsed, "TEMP") ? parsed["TEMP"][1] : missing
    )
end

load(path::AbstractString) = open(load, path, "r")
load(f::File{format"SFRM"}) = load(open(f).io)
