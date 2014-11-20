arr = [:a, :b, :c]
bmap = datalabelmap(arr, Int)
@test isa(bmap.v2i, Dict{Symbol,Int})
@test isa(bmap.i2v, Dict{Int,Symbol})

for (i,v) in enumerate(arr)
	@test encode(bmap, v) == i
	@test decode(bmap, i) == v
end
@test encode(bmap, NA) == 4
@test encode(bmap, [:c, :b, :a]) == [3, 2, 1]
@test decode(bmap, [3, 2, 1]) == [:c, :b, :a]
@test isa(decode(bmap, 4), NAtype)

darr = DataArray([:a, :a, :b, :c])
darr[2] = NA
@test encode(bmap, darr) == [1, 4, 2, 3]
@test isa(decode(bmap, [1,4,2,3])[2], NAtype)
@test dropna(decode(bmap, [1,4,2,3])) == [:a,:b,:c]

@test nlabels(bmap) == 4
@test_throws KeyError encode(bmap, :d)
@test_throws KeyError decode(bmap, -1)

@test supports_encoding(bmap, Symbol)
@test supports_encoding(bmap, NAtype)
@test supports_encoding(bmap, Int) == false
@test supports_decoding(bmap, Symbol) == false
@test supports_decoding(bmap, NAtype) == false
@test supports_decoding(bmap, Int)

@test supports_encoding(bmap, :a)
@test supports_encoding(bmap, NA)
@test supports_encoding(bmap, 1) == false
@test supports_decoding(bmap, :a) == false
@test supports_decoding(bmap, NA) == false
@test supports_decoding(bmap, 1)