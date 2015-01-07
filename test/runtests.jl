using BinMaps
using Base.Test
using DataArrays

function array_matches{S<:Integer, T<:Integer}(arr::AbstractVector{S}, arr2::AbstractVector{T})
	n = length(arr)
	@assert(length(arr2) == n)
	for i = 1 : n
		if arr[i] != arr2[i]
			return false
		end
	end
	true
end
function array_matches{S<:Real, T<:Real}(arr::AbstractVector{S}, arr2::AbstractVector{T}, abs_tolerance::FloatingPoint)
	n = length(arr)
	@assert(length(arr2) == n)
	for i = 1 : n
		if abs(arr[i] - arr2[i]) > abs_tolerance
			return false
		end
	end
	true
end

@test array_matches(binedges(DISCRETIZE_UNIFORMWIDTH, 2, [1.0,2.0,3.0,4.0,5.0,6.0]),  [1,  3.5,  6], 0.1)
@test array_matches(binedges(DISCRETIZE_UNIFORMWIDTH, 2, [6.0,2.0,30.0,4.0,5.0,1.0]), [1, 15.5, 30], 0.1)
@test array_matches(binedges(DISCRETIZE_UNIFORMWIDTH, 3, [1.0,2.0,3.0,4.0,5.0,6.0,7.0]),  [1, 3, 5, 7], 0.1)

@test array_matches(binedges(DISCRETIZE_UNIFORMCOUNT, 2, [1.0,2.0,3.0,4.0,5.0,6.0]), [1.0, 3.0, 6.0], 0.1)
@test array_matches(binedges(DISCRETIZE_UNIFORMCOUNT, 2, [6.0,2.0,3.0,4.0,5.0,1.0]), [1.0, 3.0, 6.0], 0.1)
@test array_matches(binedges(DISCRETIZE_UNIFORMCOUNT, 3, [1.0,2.0,3.0,4.0,5.0,6.0]), [1, 2, 4, 6], 0.1)

include("test_labelmap.jl")
include("test_datalabelmap.jl")
include("test_binmap.jl")
include("test_databinmap.jl")
