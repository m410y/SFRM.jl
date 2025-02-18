function load(io::IO)
    header = read_header(io)
    parsed = parse_header(header)
    image = read_image(io, parsed)
    parsed["IMG"] = image
    parsed
end

load(path::AbstractString) = open(load, path, "r")
load(f::File{format"SFRM"}) = load(open(f).io)
