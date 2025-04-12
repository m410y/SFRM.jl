export SiemensFrame

struct SiemensFrame
    image::AbstractArray
    header::AbstractDict
end

const HEADER_KEYS = IdDict(
    :type => "TYPE",
    :filename => "FILENAM",
    :created => "CREATED",
    :time => "CUMULAT",
    :angles => "ANGLES",
    :axis => "AXIS",
    :increment => "INCREME",
    :target => "TARGET",
    :voltage => "SOURCEK",
    :current => "SOURCEM"
)

const HEADER_KEYS_INDEXED = IdDict(
    :distance => ("DISTANC", 2),
    :tth => ("ANGLES", 1),
    :omega => ("ANGLES", 2),
    :phi => ("ANGLES", 3),
    :chi => ("ANGLES", 4)
    :pix512percm => ("DETTYPE", 2)
)

function Base.propertynames(::SiemensFrame)
    union(keys(HEADER_KEYS), keys(HEADER_KEYS_INDEXED), fieldnames(SiemensFrame))
end

function Base.getproperty(sfrm::SiemensFrame, name::Symbol)
    if haskey(HEADER_KEYS, name)
        key = HEADER_KEYS[name]
        sfrm.header[key]
    elseif haskey(HEADER_KEYS_INDEXED, name)
        key, idx = HEADER_KEYS_INDEXED[name]
        sfrm.header[key][idx]
    else
        getfield(sfrm, name)
    end
end

function Base.setproperty!(sfrm::SiemensFrame, name::Symbol, x)
    if haskey(HEADER_KEYS, name)
        key = HEADER_KEYS[name]
        sfrm.header[key] = x
    elseif haskey(HEADER_KEYS_INDEXED, name)
        key, idx = HEADER_KEYS_INDEXED[name]
        sfrm.header[key][idx] = x
    else
        setfield!(sfrm, name, x)
    end
end

function Base.show(io::IO, ::MIME"text/plain", sfrm::SiemensFrame)
    println(io, summary(sfrm), ":")
    println(io, "  ", summary(sfrm.image))
    println(io, "  general:")
    println(io, "    type: ", sfrm.type)
    println(io, "    filename: ", sfrm.filename)
    println(io, "    created: ", sfrm.created)
    println(io, "  setting:")
    println(io, "    time: ", sfrm.time, " s")
    println(io, "    distance: ", sfrm.distance, " mm")
    println(io, "    angles: ", join(sfrm.angles, "°, "), "°")
    if sfrm.increment != 0
        println(io, "    axis: ", sfrm.axis)
        println(io, "    increment: ", sfrm.increment, "°")
    end
    println(io, "  source:")
    println(io, "    target: ", sfrm.target)
    println(io, "    voltage: ", sfrm.voltage, " kV")
    print(io, "    current: ", sfrm.current, " mA")
end
