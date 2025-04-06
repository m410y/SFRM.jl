function save(io::IO, sfrm::SiemensFrame)
    comp = compress_100(sfrm.image)
    ending = let ending = copy(sfrm.angles)
        ending[sfrm.axis] += sfrm.increment
        ending
    end
    header = @sprintf(
        "FORMAT :100                                                                     "*
        "VERSION:18                                                                      "*
        "HDRBLKS:15                                                                      "*
"TYPE   :%-72s"*
"SITE   :UNKNOWN                                                                 "
"MODEL  :Booster[A112169] with FixedChiStage                                     "
"USER   :UNKNOWN                                                                 "
"SAMPLE :Unknown                                                                 "
"SETNAME:Unknown                                                                 "
"RUN    :1                                                                       "
"SAMPNUM:0                                                                       "
"TITLE  :                                                                        "
"TITLE  :                                                                        "
"TITLE  :                                                                        "
"TITLE  :                                                                        "
"TITLE  :                                                                        "
"TITLE  :                                                                        "
"TITLE  :                                                                        "
"TITLE  :                                                                        "
"NCOUNTS:%-35d0                                    "
"NOVERFL:%-23d%-23d%-26d"
"MINIMUM:%-72d"
"MAXIMUM:%-72d"
"NONTIME:0                                                                       "
"NLATE  :0                                                                       "
"FILENAM:%-72s"
CREATED:%-36s%-36s
CUMULAT:%-72f
ELAPSDR:%-72f
ELAPSDA:%-72f
OSCILLA:0                                                                       
NSTEPS :0                                                                       
RANGE  :%-72f
START  :%-72f
INCREME:%-72f
NUMBER :0                                                                       
NFRAMES:1                                                                       
ANGLES :%-17f%-17f%-17f%-21f
NOVER64:0                      0                      0                         
NPIXELB:%-35d%-35d
NROWS  :%-35d1                                    
NCOLS  :%-35d1                                    
WORDORD:0                                                                       
LONGORD:0                                                                       
TARGET :%-72s
SOURCEK:%-72f
SOURCEM:%-72f
FILTER :                                                                        
CELL   :1.000000      1.000000      1.000000      90.000000     90.000000       
CELL   :90.000000                                                               
MATRIX :1.000000      0.000000      0.000000      0.000000      1.000000        
MATRIX :0.000000         0.000000         0.000000         1.000000             
LOWTEMP:1  2685       -1498      TEMP: 300.00 0.0000 0                          
ZOOM   :0.500000               0.500000               1.000000                  
CENTER :386.956900       503.363600       386.956900       503.363600           
DISTANC:%-35f%-37f
TRAILER:-1                                                                      
COMPRES:0                                                                       
LINEAR :1.000000                           0.000000                             
PHD    :0.900000                           0.051000                             
PREAMP :0.000000                                                                
CORRECT:INTERNAL, s/n: A112169 Done inside firmware                             
WARPFIL:LINEAR                                                                  
WAVELEN:%-17f%-17f%-17f%-21f
MAXXY  :108.000000                         154.000000                           
AXIS   :%-72d
ENDING :%-17f%-17f%-17f%-21f
DETPAR :0.000000      0.000000      0.000000      -0.164000     0.335000        
DETPAR :0.008000                                                                
LUT    :BB.LUT                                                                  
DISPLIM:0.000000                           63.000000                            
PROGRAM:BIS V6.2.14/2020-04-30                                                  
ROTATE :0                                                                       
BITMASK:\$NULL                                                                   
OCTMASK:0           0           0           767         767         1790        
OCTMASK:1023                               1023                                 
ESDCELL:0.000000      0.000000      0.000000      0.000000      0.000000        
ESDCELL:0.000000                                                                
DETTYPE:CMOS-PHOTONII        36.954918   1.004000    0 0.425000    0.035000    1
NEXP   :1             0             %-14d0             2               
CCDPARM:475.275000    9.800000      259.924900    0.000000      9828600.000000  
CHEM   :                                                                        
MORPH  :                                                                        
CCOLOR :                                                                        
CSIZE  :                                                                        
DNSMET :                                                                        
DARK   :INTERNAL, s/n: A112169 Done inside firmware                             
AUTORNG:0.000000      0.000000      0.000000      0.000000      9828599.000000  
ZEROADJ:0.000000         0.000000         0.000000         0.000000             
XTRANS :0.000000               0.000000               0.000000                  
HKL&XY :0.000000      0.000000      0.000000      0.000000      0.000000        
        "AXES2  :0.000000         0.000000         0.000000         0.000000             "
        "ENDING2:0.000000         0.000000         0.000000         0.000000             "
        "FILTER2:0.000000         0.000000         0.100000         1.200000             "
        "LEPTOS :                                                                        "
        "CFR: HDR: IMG: ...............................................................\x1a\x04",
        sfrm.type,
        sum(sfrm.image),
        length(comp.under),
        length(comp.over1),
        length(comp.over2),
        minimum(sfrm.image),
        maximum(sfrm.image),
        sfrm.filename,
        Dates.format(sfrm.created, dateformat"d-u-y"),
        Dates.format(sfrm.created, dateformat"HH:MM:SS"),
        sfrm.time,
        sfrm.time,
        sfrm.time,
        abs(sfrm.increment),
        sfrm.angles[sfrm.axis],
        sfrm.increment,
        sfrm.angles...,
        sizeof(eltype(comp.data)),
        sizeof(eltype(comp.under)),
        size(sfrm.image, 2),
        size(sfrm.image, 1),
        sfrm.target,
        sfrm.voltage,
        sfrm.current,
        sfrm.distance / 10 - 1.004,
        sfrm.distance / 10,
        sfrm.wavelengths...,
        sfrm.axis,
        ending...,
        comp.baseline,
    )
    @show length(header)
end
