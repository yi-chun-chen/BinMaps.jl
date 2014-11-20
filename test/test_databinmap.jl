
arr = [0.0, 0.25, 0.5, 0.75, 1.0]
bmap = databinmap(arr, 3, Uint8)
@test isa(bmap.i2bin, Dict{Int,Uint8})
@test isa(bmap.bin2i, Dict{Uint8,Int})
@test bmap.nbins == 3
@test bmap.force_outliers_to_closest

bmap = databinmap(DataArray(arr), 3, Uint8)
@test isa(bmap.i2bin, Dict{Int,Uint8})
@test isa(bmap.bin2i, Dict{Uint8,Int})
@test bmap.nbins == 3
@test bmap.force_outliers_to_closest

@test encode(bmap,  0.0) == 1
@test encode(bmap, -1.0) == 1
@test encode(bmap,  0.1) == 1
@test encode(bmap,  0.6) == 2
@test encode(bmap,  1.0) == 2
@test encode(bmap,  1.5) == 2
@test encode(bmap,  NA ) == 3
@test encode(bmap,  [0.2,0.6,0.2]) == [1,2,1]

@test 0.0 <= decode(bmap, uint8(1)) <= 0.5
@test isa(decode(bmap, uint8(3)), NAtype)

@test nlabels(bmap) == 3
@test_throws KeyError decode(bmap, uint8(50))

@test supports_encoding(bmap, Float64)
@test supports_encoding(bmap, NAtype)
@test supports_encoding(bmap, Uint8) == false
@test supports_decoding(bmap, Float64) == false
@test supports_decoding(bmap, NAtype) == false
@test supports_decoding(bmap, Uint8)

@test supports_encoding(bmap, 1.0)
@test supports_encoding(bmap, NA)
@test supports_encoding(bmap, uint8(1)) == false
@test supports_decoding(bmap, 1.0) == false
@test supports_decoding(bmap, NA) == false
@test supports_decoding(bmap, uint8(1))