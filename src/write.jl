function write_key(io::IO, key::AbstractString, val::AbstractString)
    if length(val) != sizeof(val)
        error("Unicode characters not supported")
    end

    for n in 1:(LINE_LEN - KEY_LEN):length(val)
        write(io, @sprintf("%-*s:%*s", KEY_LEN - 1, key, LINE_LEN - KEY_LEN, val[n:end]))
    end
end