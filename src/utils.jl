function ij_to_xy(i::Integer, j::Integer, size::NTuple{2,Integer})
    i - 1, size[2] - j
end

function xy_to_ij(x::Integer, y::Integer, size::NTuple{2,Integer})
    x + 1, size[2] - y
end
