# BinMaps.jl
#   Provides utilities for discretizing & un-discretizing data

module BinMaps

using DataArrays

export AbstractBinMap, LabelMap, DataLabelMap, BinMap, DataBinMap
export labelmap, datalabelmap, binmap, databinmap
export encode, decode, nlabels, supports_encoding, supports_decoding
export DiscretizatonAlgorithm, DISCRETIZE_UNIFORMWIDTH, DISCRETIZE_UNIFORMCOUNT
export binedges

abstract AbstractBinMap{T,S}
	# T indicates the undiscretized type
	# S indicates the discretized type, typically an Integer type

supports_encoding{T,S}(::AbstractBinMap{T,S}, typ::Type) = typ <: T
supports_encoding{T,S}(::AbstractBinMap{T,S}, x) = isa(x, T)

supports_decoding{T,S}(::AbstractBinMap{T,S}, typ::Type) = typ <: S
supports_decoding{T,S}(::AbstractBinMap{T,S}, x) = isa(x, S)

#######################################################


abstract DiscretizatonAlgorithm
immutable Discretize_UniformWidth <: DiscretizatonAlgorithm end
immutable Discretize_UniformCount <: DiscretizatonAlgorithm end
const DISCRETIZE_UNIFORMWIDTH = Discretize_UniformWidth()
const DISCRETIZE_UNIFORMCOUNT = Discretize_UniformCount()

function binedges{T<:FloatingPoint}(::Discretize_UniformWidth, nbins::Integer, data::AbstractArray{T})
	# create a set of uniform-width bins
	lo, hi = extrema(data)
	convert(Vector{T}, linspace(lo, hi, nbins+1))
end
function binedges{T<:FloatingPoint}(::Discretize_UniformCount, nbins::Integer, data::AbstractArray{T})
	# create a set of uniform-count bins

	n = length(data)
	n >= nbins || error("too many bins requested")
	p = sortperm(data)
	counts_per_bin, remainder = div(n,nbins), rem(n,nbins)
	retval = Array(T, nbins+1)
	retval[1] = data[p[1]]
	retval[end] = data[p[end]]

	ind = 0
	for i = 2 : nbins
		counts = counts_per_bin + (remainder > 0.0 ? 1 : 0)
		remainder -= 1.0
		ind += counts
		retval[i] = data[p[i]]
		retval[i-1] != retval[i] || error("binedges non-unique")
	end

	retval
end

#######################################################

include("labelmap.jl")
include("datalabelmap.jl")
include("binmap.jl")
include("databinmap.jl")

end # end modules