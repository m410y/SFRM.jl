const WAVELENGTHS = Dict(
    "mo" => [0.71073, 0.7093, 0.71359, 0.63229],
    "cu" => [1.54184, 1.5406, 1.54439, 1.39222],
)

function save(io::IO, sfrm::SiemensFrame)
    comp = compress_100(vec(reverse(transpose(sfrm.image), dims = 2)))
    ending = copy(sfrm.angles)
    ending[sfrm.axis] += sfrm.increment
    @printf io "FORMAT :%-72d" 100
    @printf io "VERSION:%-72d" 18
    @printf io "HDRBLKS:%-72d" 15
    @printf io "TYPE   :%-72s" sfrm.type
    @printf io "SITE   :%-72s" "UNKNOWN"
    @printf io "MODEL  :%-72s" "Booster[A112169] with FixedChiStage"
    @printf io "USER   :%-72s" "UNKNOWN"
    @printf io "SAMPLE :%-72s" "Unknown"
    @printf io "SETNAME:%-72s" "Unknown"
    @printf io "RUN    :%-72d" 1
    @printf io "SAMPNUM:%-72d" 0
    @printf io "TITLE  :%-72s" "Created by SFRM.jl"
    @printf io "TITLE  :%-72s" ""
    @printf io "TITLE  :%-72s" ""
    @printf io "TITLE  :%-72s" ""
    @printf io "TITLE  :%-72s" ""
    @printf io "TITLE  :%-72s" ""
    @printf io "TITLE  :%-72s" ""
    @printf io "TITLE  :%-72s" ""
    @printf io "NCOUNTS:%-35d %-35d " sum(sfrm.image) 0
    @printf io "NOVERFL:%-23d %-23d %-23d " (isempty(comp.under) ? -1 : length(comp.under)) length(
        comp.over1,
    ) length(comp.over2)
    @printf io "MINIMUM:%-72d" minimum(sfrm.image)
    @printf io "MAXIMUM:%-72d" maximum(sfrm.image)
    @printf io "NONTIME:%-72d" 0
    @printf io "NLATE  :%-72d" 0
    @printf io "FILENAM:%-72s" sfrm.filename
    @printf io "CREATED:%-35s %-35s " Dates.format(sfrm.created, dateformat"d-u-yyyy") Dates.format(
        sfrm.created,
        dateformat"HH:MM:SS",
    )
    @printf io "CUMULAT:%-72f" sfrm.time
    @printf io "ELAPSDR:%-72f" sfrm.time
    @printf io "ELAPSDA:%-72f" sfrm.time
    @printf io "OSCILLA:%-72d" 0
    @printf io "NSTEPS :%-72d" 0
    @printf io "RANGE  :%-72f" abs(sfrm.increment)
    @printf io "START  :%-72f" sfrm.angles[sfrm.axis]
    @printf io "INCREME:%-72f" sfrm.increment
    @printf io "NUMBER :%-72d" 0
    @printf io "NFRAMES:%-72d" 1
    @printf io "ANGLES :%-17f %-17f %-17f %-17f " sfrm.angles...
    @printf io "NOVER64:%-23d %-23d %-23d " 0 0 0
    @printf io "NPIXELB:%-35d %-35d " sizeof.(eltype.([comp.data, comp.under]))...
    @printf io "NROWS  :%-35d %-35d " size(sfrm.image, 1) 1
    @printf io "NCOLS  :%-35d %-35d " size(sfrm.image, 2) 1
    @printf io "WORDORD:%-72d" 0
    @printf io "LONGORD:%-72d" 0
    @printf io "TARGET :%-72s" sfrm.target
    @printf io "SOURCEK:%-72f" sfrm.voltage
    @printf io "SOURCEM:%-72f" sfrm.current
    @printf io "FILTER :%-72s" ""
    @printf io "CELL   :%-13f %-13f %-13f %-13f %-15f " 1.0 1.0 1.0 90.0 90.0
    @printf io "CELL   :%-72f" 90.0
    @printf io "MATRIX :%-13f %-13f %-13f %-13f %-15f " 1.0 0.0 0.0 0.0 1.0
    @printf io "MATRIX :%-17f %-17f %-17f %-17f " 0.0 0.0 0.0 1.0
    @printf io "LOWTEMP:%-23d %-23d %-23d " 1 2485 -1398
    @printf io "ZOOM   :%-23f %-23f %-23f " 0.5 0.5 1.0
    @printf io "CENTER :%-17f %-17f %-17f %-17f " 386.9569 503.3636 386.9569 503.3636
    @printf io "DISTANC:%-35f %-35f " (sfrm.distance / 10 - 0.1004) (sfrm.distance / 10)
    @printf io "TRAILER:%-72d" -1
    @printf io "COMPRES:%-72s" "0"
    @printf io "LINEAR :%-35f %-35f " 1.0 0.0
    @printf io "PHD    :%-35f %-35f " 0.9 0.051
    @printf io "PREAMP :%-72f" 0.0
    @printf io "CORRECT:%-72s" "INTERNAL, s/n: A112169 Done inside firmware"
    @printf io "WARPFIL:%-72s" "LINEAR"
    @printf io "WAVELEN:%-17f %-17f %-17f %-17f " WAVELENGTHS[lowercase(sfrm.target)]...
    @printf io "MAXXY  :%-35f %-35f " 498.0 791.0
    @printf io "AXIS   :%-72d" sfrm.axis
    @printf io "ENDING :%-17f %-17f %-17f %-17f " ending...
    @printf io "DETPAR :%-13f %-13f %-13f %-13f %-15f " 0.0 0.0 0.0 -0.164 0.335
    @printf io "DETPAR :%-72f" 0.0008
    @printf io "LUT    :%-72s" "BB.LUT"
    @printf io "DISPLIM:%-35f %-35f " 0.0 63.0
    @printf io "PROGRAM:%-72s" "BIS V6.2.14/2020-04-30"
    @printf io "ROTATE :%-72d" 0
    @printf io "BITMASK:%-72s" "\$NULL"
    @printf io "OCTMASK:%-11d %-11d %-11d %-11d %-11d %-11d " 0 0 0 767 767 1790
    @printf io "OCTMASK:%-35d %-35d " 1023 1023
    @printf io "ESDCELL:%-13f %-13f %-13f %-13f %-15f " 0.0 0.0 0.0 0.0 0.0
    @printf io "ESDCELL:%-72f" 0.0
    @printf io "DETTYPE:%-20s %-11f %-11f %-1d %-11f %-11f %-1d" "CMOS-PHOTONII" 36.954918 1.004 0 0.425 0.035 1
    @printf io "NEXP   :%-13d %-13d %-13d %-13d %-15d " 1 0 comp.baseline 0 2
    @printf io "CCDPARM:%-13f %-13f %-13f %-13f %-15f " 475.275 9.8 259.9249 0.0 9828600.0
    @printf io "CHEM   :%-72s" ""
    @printf io "MORPH  :%-72s" ""
    @printf io "CCOLOR :%-72s" ""
    @printf io "CSIZE  :%-72s" ""
    @printf io "DNSMET :%-72s" ""
    @printf io "DARK   :%-72s" "INTERNAL, s/n: A112169 Done inside firmware"
    @printf io "AUTORNG:%-13f %-13f %-13f %-13f %-15f " 0.0 0.0 0.0 0.0 9828599.0
    @printf io "ZEROADJ:%-17f %-17f %-17f %-17f " 0.0 0.0 0.0 0.0
    @printf io "XTRANS :%-23f %-23f %-23f " 0.0 0.0 0.0
    @printf io "HKL&XY :%-13f %-13f %-13f %-13f %-15f " 0.0 0.0 0.0 0.0 0.0
    @printf io "AXES2  :%-17f %-17f %-17f %-17f " 0.0 0.0 0.0 0.0
    @printf io "ENDING2:%-17f %-17f %-17f %-17f " 0.0 0.0 0.0 0.0
    @printf io "FILTER2:%-17f %-17f %-17f %-17f " 0.0 0.0 0.1 1.2
    @printf io "LEPTOS :%-72s" ""
    write(io, "CFR: HDR: IMG: " * "."^63 * "\x1a\x04")
    write_aligned_array(io, comp.data)
    write_aligned_array(io, comp.under)
    write_aligned_array(io, comp.over1)
    write_aligned_array(io, comp.over2)
    nothing
end

function save(path::AbstractString, sfrm::SiemensFrame)
    open(path, "w") do io
        save(io, sfrm)
    end
end
save(f::File{format"SFRM"}, sfrm::SiemensFrame) = save(open(f).io, sfrm)
