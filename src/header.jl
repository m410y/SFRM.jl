function read_line(io::IO)
    line = UInt8[]
    readbytes!(io, line, LINE_LEN)
    m = match(r"(\S+)\s*:(.*)", String(line))
    m.captures
end

function read_blocks(io::IO, blocks::Integer)
    lines = div(BLOCK_SIZE * blocks, LINE_LEN)
    header = Dict()
    for _ in 1:lines
        key, value = read_line(io::IO)
        key = String(rstrip(key))
        if key in keys(header)
            header[key] *= value
        else
            header[key] = value
        end
    end
    header
end

function read_header(io::IO)
    header = read_blocks(io, BLOCKS_MIN)
    blocks_remain = parse(Int, strip(header["HDRBLKS"])) - BLOCKS_MIN
    merge!(header, read_blocks(io, blocks_remain))
    header
end

function parse_header(header::AbstractDict)
    parsed = Dict()
    for (key, val) in header
        if key in keys(SPECIFIC_PARSERS)
            parser = SPECIFIC_PARSERS[key]
            merge!(parsed, parser(val))
        else
            parsed[key] = parse_default(val)
        end
    end
    parsed
end
