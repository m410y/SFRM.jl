const WAVELENGTHS = Dict(
    "mo" => [0.71073, 0.7093, 0.71359, 0.63229],
    "cu" => [1.54184, 1.5406, 1.54439, 1.39222],
)

function save(io::IO, sfrm::SiemensFrame; filename = sfrm.header["FILENAM"])
    format = 100
    version = 18
    hdr = sfrm.header
    if get(hdr, "FORMAT", format) != format
        @warn "Format will be converted to $(format)"
    end
    if get(hdr, "VERSION", version) != version
        @warn "Version will be converted to $(version)"
    end
    flat = vec(reverse(transpose(sfrm.image), dims = 2))
    comment = get(hdr, "TITLE", "")
    comment *= " Created by SFRM.jl"
    if length(comment) < 8 * 72
        comment *= " "^(8 * 72 - length(comment))
    end
    npixelb = get(hdr, "NPIXELB", [1, 1])
    date_str = Dates.format(now(), dateformat"d-u-yyyy")
    time_str = Dates.format(now(), dateformat"HH:MM:SS")
    cell = get(hdr, "CELL", [1, 1, 1, 90, 90, 90])
    matrix = get(hdr, "MATRIX", [1, 0, 0, 0, 1, 0, 0, 0, 1])
    detpar = get(hdr, "DETPAR", zeros(6))
    octmask = get(hdr, "OCTMASK", zeros(8))
    esdcell =
        get(hdr, "ESDCELL", [0.02, 0.02, 0.02, rad2deg(0.02), rad2deg(0.02), rad2deg(0.02)])
    nexp = get(hdr, "NEXP", [2, 0, 0, 0, 0])
    comp = compress_100(
        flat,
        dtype = unsigned_integer(npixelb[1]),
        utype = signed_integer(npixelb[2]),
        baseline = nexp[3],
    )
    underlen = isempty(comp.under) ? -1 : length(comp.under)
    startpos = position(io)
    @printf io "FORMAT :%-72d" format
    @printf io "VERSION:%-72d" version
    @printf io "HDRBLKS:%-72d" 15
    @printf io "TYPE   :%-72s" get(hdr, "TYPE", "Scan frame")
    @printf io "SITE   :%-72s" get(hdr, "SITE", "?")
    @printf io "MODEL  :%-72s" get(hdr, "MODEL", "?")
    @printf io "USER   :%-72s" get(hdr, "USER", "?")
    @printf io "SAMPLE :%-72s" get(hdr, "SAMPLE", "?")
    @printf io "SETNAME:%-72s" get(hdr, "SETNAME", "?")
    @printf io "RUN    :%-72d" get(hdr, "RUN", 1)
    @printf io "SAMPNUM:%-72d" get(hdr, "SAMPNUM", 1)
    for i = 1:8
        @printf io "TITLE  :%-72s" comment[(1+72*(i-1)):(72*i)]
    end
    @printf io "NCOUNTS:%-35d %-35d " sum(sfrm.image) 0
    @printf io "NOVERFL:%-23d %-23d %-23d " underlen length(comp.over1) length(comp.over2)
    @printf io "MINIMUM:%-72d" minimum(sfrm.image)
    @printf io "MAXIMUM:%-72d" maximum(sfrm.image)
    @printf io "NONTIME:%-72d" get(hdr, "NONTIME", 0)
    @printf io "NLATE  :%-72d" get(hdr, "NLATE", 0)
    @printf io "FILENAM:%-72s" filename
    @printf io "CREATED:%-35s %-35s " date_str time_str
    @printf io "CUMULAT:%-72f" get(hdr, "CUMULAT", 0)
    @printf io "ELAPSDR:%-72f" get(hdr, "ELAPSDR", 0)
    @printf io "ELAPSDA:%-72f" get(hdr, "ELAPSDA", 0)
    @printf io "OSCILLA:%-72d" get(hdr, "OSCILLA", 0)
    @printf io "NSTEPS :%-72d" get(hdr, "NSTEPS", 1)
    @printf io "RANGE  :%-72f" get(hdr, "RANGE", 0)
    @printf io "START  :%-72f" get(hdr, "START", 0)
    @printf io "INCREME:%-72f" get(hdr, "INCREME", 0)
    @printf io "NUMBER :%-72d" get(hdr, "NUMBER", 0)
    @printf io "NFRAMES:%-72d" get(hdr, "NFRAMES", 1)
    @printf io "ANGLES :%-17f %-17f %-17f %-17f " get(hdr, "ANGLES", zeros(4))...
    @printf io "NOVER64:%-23d %-23d %-23d " 0 0 0
    @printf io "NPIXELB:%-35d %-35d " sizeof.(eltype.([comp.data, comp.under]))...
    @printf io "NROWS  :%-35d %-35d " size(sfrm.image, 1) 1
    @printf io "NCOLS  :%-35d %-35d " size(sfrm.image, 2) 1
    @printf io "WORDORD:%-72d" 0
    @printf io "LONGORD:%-72d" 0
    @printf io "TARGET :%-72s" get(hdr, "TARGET", "?")
    @printf io "SOURCEK:%-72f" get(hdr, "SOURCEK", 1)
    @printf io "SOURCEM:%-72f" get(hdr, "SOURCEM", 1)
    @printf io "FILTER :%-72s" get(hdr, "FILTER", 1)
    @printf io "CELL   :%-13f %-13f %-13f %-13f %-13f   " cell[1:5]...
    @printf io "CELL   :%-72f" cell[6]...
    @printf io "MATRIX :%-13f %-13f %-13f %-13f %-13f   " matrix[1:5]...
    @printf io "MATRIX :%-17f %-17f %-17f %-17f " matrix[6:9]...
    if haskey(hdr, "LOWTEMP") && length(hdr["LOWTEMP"]) > 3
        @printf io "LOWTEMP:%-2d %-10d %-10d TEMP: %-14.2f %-14.4f %-10d " hdr["LOWTEMP"]...
    else
        @printf io "LOWTEMP:%-23d %-23d %-23d " get(hdr, "LOWTEMP", [0, -27315, 0])...
    end
    @printf io "ZOOM   :%-23f %-23f %-23f " get(hdr, "ZOOM", [0, 0, 1])...
    @printf io "CENTER :%-17f %-17f %-17f %-17f " get(hdr, "CENTER", zeros(4))...
    @printf io "DISTANC:%-35f %-35f " get(hdr, "DISTANC", zeros(2))...
    @printf io "TRAILER:%-72d" get(hdr, "TRAILER", 0)
    @printf io "COMPRES:%-72s" get(hdr, "COMPRES", "none")
    @printf io "LINEAR :%-35f %-35f " 1 0
    @printf io "PHD    :%-35f %-35f " get(hdr, "PHD", zeros(2))...
    if haskey(hdr, "PREAMP") && length(hdr["PREAMP"]) > 1
        @printf io "PREAMP :%-35d %-35d " get["PREAMP"]...
    else
        @printf io "PREAMP :%-72d" get(hdr, "PREAMP", 1)
    end
    @printf io "CORRECT:%-72s" get(hdr, "CORRECT", "")
    @printf io "WARPFIL:%-72s" get(hdr, "WARPFIL", "")
    if haskey(hdr, "WAVELEN") && length(hdr["WAVELEN"]) > 3
        @printf io "WAVELEN:%-17f %-17f %-17f %-17f " hdr["WAVELEN"]...
    else
        @printf io "WAVELEN:%-23f %-23f %-23f " get(hdr, "WAVELEN", ones(3))...
    end
    @printf io "MAXXY  :%-35f %-35f " get(hdr, "MAXXY", zeros(2))...
    @printf io "AXIS   :%-72d" get(hdr, "AXIS", 1)
    @printf io "ENDING :%-17f %-17f %-17f %-17f " get(hdr, "ENDING", zeros(4))...
    @printf io "DETPAR :%-13f %-13f %-13f %-13f %-13f   " detpar[1:5]...
    @printf io "DETPAR :%-72f" detpar[6]
    @printf io "LUT    :%-72s" get(hdr, "LUT", "lut")
    @printf io "DISPLIM:%-35f %-35f " get(hdr, "DISPLIM", zeros(2))...
    @printf io "PROGRAM:%-72s" get(hdr, "PROGRAM", "?")
    @printf io "ROTATE :%-72d" get(hdr, "ROTATE", 0)
    @printf io "BITMASK:%-72s" get(hdr, "BITMASK", "\$NULL")
    @printf io "OCTMASK:%-11d %-11d %-11d %-11d %-11d %-11d " octmask[1:6]...
    @printf io "OCTMASK:%-35d %-35d " octmask[7:8]...
    @printf io "ESDCELL:%-13f %-13f %-13f %-13f %-13f   " esdcell[1:5]...
    @printf io "ESDCELL:%-72f" esdcell[6]
    @printf io "DETTYPE:%-20s %-11f %-11f %-1d %-11f %-11f %-1d" get(
        hdr,
        "DETTYPE",
        ["virtual", zeros(6)...],
    )...
    @printf io "NEXP   :%-13d %-13d %-13d %-13d %-13d   " nexp[1:5]...
    @printf io "CCDPARM:%-13f %-13f %-13f %-13f %-15f " get(
        hdr,
        "CCDPARM",
        [0, 1, 1, 0, 65535],
    )...
    @printf io "CHEM   :%-72s" get(hdr, "CHEM", "?")
    @printf io "MORPH  :%-72s" get(hdr, "MORPH", "?")
    @printf io "CCOLOR :%-72s" get(hdr, "CCOLOR", "?")
    @printf io "CSIZE  :%-72s" get(hdr, "CSIZE", "?")
    @printf io "DNSMET :%-72s" get(hdr, "DNSMET", "?")
    @printf io "DARK   :%-72s" get(hdr, "DARK", "?")
    @printf io "AUTORNG:%-13f %-13f %-13f %-13f %-15f " get(hdr, "AUTORNG", zeros(5))...
    @printf io "ZEROADJ:%-17f %-17f %-17f %-17f " get(hdr, "ZEROADJ", zeros(4))...
    @printf io "XTRANS :%-23f %-23f %-23f " get(hdr, "XTRANS", zeros(3))...
    @printf io "HKL&XY :%-13f %-13f %-13f %-13f %-13f   " get(hdr, "HKL&XY", zeros(5))...
    @printf io "AXES2  :%-17f %-17f %-17f %-17f " get(hdr, "AXES2", zeros(4))...
    @printf io "ENDING2:%-17f %-17f %-17f %-17f " get(hdr, "ENDING2", zeros(4))...
    @printf io "FILTER2:%-17f %-17f %-17f %-17f " get(hdr, "FILTER2", [0, 0, 0, 1])...
    @printf io "LEPTOS :%-72s" get(hdr, "LEPTOS", "")
    write(io, "CFR: HDR: IMG: " * "."^63 * "\x1a\x04")
    write_aligned_array(io, comp.data)
    write_aligned_array(io, comp.under)
    write_aligned_array(io, comp.over1)
    write_aligned_array(io, comp.over2)
    position(io) - startpos
end

function save(path::AbstractString, sfrm::SiemensFrame)
    open(path, "w") do io
        save(io, sfrm)
    end
    path
end

function save(f::File{format"SFRM"}, sfrm::SiemensFrame)
    s = open(f, "w")
    save(s.io, sfrm, filename = basename(s.filename))
    s.filename
end
