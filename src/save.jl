function save(io::IO, sfrm::SiemensFrame)
    comp = compress_100(sfrm.image)
    ending = copy(sfrm.angles)
    ending[sfrm.axis] += sfrm.increment
    write(io, @sprintf "FORMAT :%-72d" 100)
    write(io, @sprintf "VERSION:%-72d" 18)
    write(io, @sprintf "HDRBLKS:%-72d" 15)
    write(io, @sprintf "TYPE   :%-72s" sfrm.type)
    write(io, @sprintf "SITE   :%-72s" "UNKNOWN")
    write(io, @sprintf "MODEL  :%-72s" "Booster[A112169] with FixedChiStage")
    write(io, @sprintf "USER   :%-72s" "UNKNOWN")
    write(io, @sprintf "SAMPLE :%-72s" "Unknown")
    write(io, @sprintf "SETNAME:%-72s" "Unknown")
    write(io, @sprintf "RUN    :%-72d" 1)
    write(io, @sprintf "SAMPNUM:%-72d" 0)
    write(io, @sprintf "TITLE  :%-72s" "Created by SFRM.jl")
    write(io, @sprintf "TITLE  :%-72s" "")
    write(io, @sprintf "TITLE  :%-72s" "")
    write(io, @sprintf "TITLE  :%-72s" "")
    write(io, @sprintf "TITLE  :%-72s" "")
    write(io, @sprintf "TITLE  :%-72s" "")
    write(io, @sprintf "TITLE  :%-72s" "")
    write(io, @sprintf "TITLE  :%-72s" "")
    write(io, @sprintf "NCOUNTS:%-35d %-35d " sum(sfrm.image) 0)
    write(
        io,
        @sprintf "NOVERFL:%-23d %-23d %-23d " (
            isempty(comp.under) ? -1 : length(comp.under)
        ) length(comp.over1) length(comp.over2)
    )
    write(io, @sprintf "MINIMUM:%-72d" minimum(sfrm.image))
    write(io, @sprintf "MAXIMUM:%-72d" maximum(sfrm.image))
    write(io, @sprintf "NONTIME:%-72d" 0)
    write(io, @sprintf "NLATE  :%-72d" 0)
    write(io, @sprintf "FILENAM:%-72s" sfrm.filename)
    write(
        io,
        @sprintf "CREATED:%-35s %-35s " Dates.format(sfrm.created, dateformat"d-u-yyyy") Dates.format(
            sfrm.created,
            dateformat"HH:MM:SS",
        )
    )
    write(io, @sprintf "CUMULAT:%-72f" sfrm.time)
    write(io, @sprintf "ELAPSDR:%-72f" sfrm.time)
    write(io, @sprintf "ELAPSDA:%-72f" sfrm.time)
    write(io, @sprintf "OSCILLA:%-72d" 0)
    write(io, @sprintf "NSTEPS :%-72d" 0)
    write(io, @sprintf "RANGE  :%-72f" abs(sfrm.increment))
    write(io, @sprintf "START  :%-72f" sfrm.angles[sfrm.axis])
    write(io, @sprintf "INCREME:%-72f" sfrm.increment)
    write(io, @sprintf "NUMBER :%-72d" 0)
    write(io, @sprintf "NFRAMES:%-72d" 1)
    write(io, @sprintf "ANGLES :%-17f %-17f %-17f %-17f " sfrm.angles...)
    write(io, @sprintf "NOVER64:%-23d %-23d %-23d " 0 0 0)
    write(
        io,
        @sprintf "NPIXELB:%-35d %-35d " sizeof(eltype(comp.data)) sizeof(
            eltype(comp.under),
        )
    )
    write(io, @sprintf "NROWS  :%-35d %-35d " size(sfrm.image, 1) 1)
    write(io, @sprintf "NCOLS  :%-35d %-35d " size(sfrm.image, 2) 1)
    write(io, @sprintf "WORDORD:%-72d" 0)
    write(io, @sprintf "LONGORD:%-72d" 0)
    write(io, @sprintf "TARGET :%-72s" sfrm.target)
    write(io, @sprintf "SOURCEK:%-72f" sfrm.voltage)
    write(io, @sprintf "SOURCEM:%-72f" sfrm.current)
    write(io, @sprintf "FILTER :%-72s" "")
    write(io, @sprintf "CELL   :%-13f %-13f %-13f %-13f %-15f " 1.0 1.0 1.0 90.0 90.0)
    write(io, @sprintf "CELL   :%-72f" 90.0)
    write(io, @sprintf "MATRIX :%-13f %-13f %-13f %-13f %-15f " 1.0 0.0 0.0 0.0 1.0)
    write(io, @sprintf "MATRIX :%-17f %-17f %-17f %-17f " 0.0 0.0 0.0 1.0)
    write(io, @sprintf "LOWTEMP:%-23d %-23d %-23d " 1 2485 -1398)
    write(io, @sprintf "ZOOM   :%-23f %-23f %-23f " 0.5 0.5 1.0)
    write(
        io,
        @sprintf "CENTER :%-17f %-17f %-17f %-17f " 386.9569 503.3636 386.9569 503.3636
    )
    write(
        io,
        @sprintf "DISTANC:%-35f %-35f " (sfrm.distance / 10 - 10.04) (sfrm.distance / 10)
    )
    write(io, @sprintf "TRAILER:%-72d" -1)
    write(io, @sprintf "COMPRES:%-72s" "0")
    write(io, @sprintf "LINEAR :%-35f %-35f " 1.0 0.0)
    write(io, @sprintf "PHD    :%-35f %-35f " 0.9 0.051)
    write(io, @sprintf "PREAMP :%-72f" 0.0)
    write(io, @sprintf "CORRECT:%-72s" "INTERNAL, s/n: A112169 Done inside firmware")
    write(io, @sprintf "WARPFIL:%-72s" "LINEAR")
    write(io, @sprintf "WAVELEN:%-17f %-17f %-17f %-17f " 0.71073 0.7093 0.71359 0.63229)
    write(io, @sprintf "MAXXY  :%-35f %-35f " 498.0 791.0)
    write(io, @sprintf "AXIS   :%-72d" sfrm.axis)
    write(io, @sprintf "ENDING :%-17f %-17f %-17f %-17f " ending...)
    write(io, @sprintf "DETPAR :%-13f %-13f %-13f %-13f %-15f " 0.0 0.0 0.0 -0.164 0.335)
    write(io, @sprintf "DETPAR :%-72f" 0.0008)
    write(io, @sprintf "LUT    :%-72s" "BB.LUT")
    write(io, @sprintf "DISPLIM:%-35f %-35f " 0.0 63.0)
    write(io, @sprintf "PROGRAM:%-72s" "BIS V6.2.14/2020-04-30")
    write(io, @sprintf "ROTATE :%-72d" 0)
    write(io, @sprintf "BITMASK:%-72s" "\$NULL")
    write(io, @sprintf "OCTMASK:%-11d %-11d %-11d %-11d %-11d %-11d " 0 0 0 767 767 1790)
    write(io, @sprintf "OCTMASK:%-35d %-35d " 1023 1023)
    write(io, @sprintf "ESDCELL:%-13f %-13f %-13f %-13f %-15f " 0.0 0.0 0.0 0.0 0.0)
    write(io, @sprintf "ESDCELL:%-72f" 0.0)
    write(
        io,
        @sprintf "DETTYPE:%-20s %-11f %-11f %-1d %-11f %-11f %-1d" "CMOS-PHOTONII" 36.954918 1.004 0 0.425 0.035 1
    )
    write(io, @sprintf "NEXP   :%-13d %-13d %-13d %-13d %-15d " 1 0 comp.baseline 0 2)
    write(
        io,
        @sprintf "CCDPARM:%-13f %-13f %-13f %-13f %-15f " 475.275 9.8 259.9249 0.0 9828600.0
    )
    write(io, @sprintf "CHEM   :%-72s" "")
    write(io, @sprintf "MORPH  :%-72s" "")
    write(io, @sprintf "CCOLOR :%-72s" "")
    write(io, @sprintf "CSIZE  :%-72s" "")
    write(io, @sprintf "DNSMET :%-72s" "")
    write(io, @sprintf "DARK   :%-72s" "INTERNAL, s/n: A112169 Done inside firmware")
    write(io, @sprintf "AUTORNG:%-13f %-13f %-13f %-13f %-15f " 0.0 0.0 0.0 0.0 9828599.0)
    write(io, @sprintf "ZEROADJ:%-17f %-17f %-17f %-17f " 0.0 0.0 0.0 0.0)
    write(io, @sprintf "XTRANS :%-23f %-23f %-23f " 0.0 0.0 0.0)
    write(io, @sprintf "HKL&XY :%-13f %-13f %-13f %-13f %-15f " 0.0 0.0 0.0 0.0 0.0)
    write(io, @sprintf "AXES2  :%-17f %-17f %-17f %-17f " 0.0 0.0 0.0 0.0)
    write(io, @sprintf "ENDING2:%-17f %-17f %-17f %-17f " 0.0 0.0 0.0 0.0)
    write(io, @sprintf "FILTER2:%-17f %-17f %-17f %-17f " 0.0 0.0 0.1 1.2)
    write(io, @sprintf "LEPTOS :%-72s" "")
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
