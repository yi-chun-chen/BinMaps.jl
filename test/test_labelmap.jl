arr = [:a, :b, :c]
bmap = labelmap(arr, Int)
@test isa(bmap.v2i, Dict{Symbol,Int})
@test isa(bmap.i2v, Dict{Int,Symbol})

for (i,v) in enumerate(arr)
	@test encode(bmap, v) == i
	@test decode(bmap, i) == v
end
@test encode(bmap, [:c, :b, :a]) == [3, 2, 1]
@test decode(bmap, [3, 2, 1]) == [:c, :b, :a]

@test nlabels(bmap) == 3
@test_throws KeyError encode(bmap, :d)
@test_throws KeyError decode(bmap, -1)

@test supports_encoding(bmap, Symbol)
@test supports_encoding(bmap, Int) == false
@test supports_decoding(bmap, Symbol) == false
@test supports_decoding(bmap, Int)

@test supports_encoding(bmap, :a)
@test supports_encoding(bmap, 1) == false
@test supports_decoding(bmap, :a) == false
@test supports_decoding(bmap, 1)