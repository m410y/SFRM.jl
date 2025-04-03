function load(io::IO)
    header = read_header(io)
    parsed = parse_header(header)
    img_raw = read_image(io, parsed)
    img = Origin(0)(transpose(reverse!(img_raw, dims=2)))
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
        temp = haskey(parsed, "TEMP") ? parsed["TEMP"][1] : missing
    )
end

load(path::AbstractString) = open(load, path, "r")
load(f::File{format"SFRM"}) = load(open(f).io)
