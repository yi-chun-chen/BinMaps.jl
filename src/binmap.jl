# BinMap
#  maps continuous values to bins
#  encoding a value will return the item associated with that bin
#  decoding a bin will sample uniformally from that bin

immutable BinMap{T<:FloatingPoint,S} <: AbstractBinMap{T,S}
	i2bin    :: Dict{Int,S}
	bin2i    :: Dict{S,Int}
	binedges :: Vector{T}
	nbins    :: Int
	force_outliers_to_closest :: Bool # if true, real values outside of the bin ranges will be forced to the nearest bin, otherwise will throw an error
	zero_bin :: Bool # if true, when decoding bin containing 0 return 0 instead of sampling
end

const BINMAP_DEFAULT_OUTLIER_FORCE = true
const BINMAP_DEFAULT_ZERO_BIN      = false

function BinMap{T<:FloatingPoint, S}(
	i2bin::Dict{Int,S}, 
	binedges::Vector{T};
	force_outliers_to_closest::Bool = BINMAP_DEFAULT_OUTLIER_FORCE,
	zero_bin::Bool = BINMAP_DEFAULT_ZERO_BIN
	)

	length(binedges) > 1 || error("Bin edges must contain at least 2 values")
    findfirst(i->binedges[i+1]<=binedges[i], [1:length(binedges)-1]) == 0 || 
    	error("Bin edges must be sorted in increasing order")

    bin2i = Dict{S,Int}()
	for (k,v) in i2bin
		bin2i[v] = k
	end
	
	BinMap{T,S}(i2bin, bin2i, binedges, length(i2bin), force_outliers_to_closest, zero_bin)
end
function binmap{T<:FloatingPoint, S<:Integer}(
	data  :: AbstractArray{T},
	nbins :: Integer,
	      :: Type{S},
	alg   :: DiscretizatonAlgorithm = DISCRETIZE_UNIFORMWIDTH;
	force_outliers_to_closest::Bool = BINMAP_DEFAULT_OUTLIER_FORCE,
	zero_bin::Bool = BINMAP_DEFAULT_ZERO_BIN
	)

	i2bin = [i=>convert(S,i) for i in 1:nbins]
	bin_edges = binedges(alg, nbins, data)

	BinMap(i2bin, bin_edges, 
		force_outliers_to_closest=force_outliers_to_closest, 
		zero_bin=zero_bin)
end
function binmap{T<:FloatingPoint, S<:Integer}(
	binedges :: Vector{T},
	         :: Type{S};
	force_outliers_to_closest::Bool = BINMAP_DEFAULT_OUTLIER_FORCE,
	zero_bin::Bool = BINMAP_DEFAULT_ZERO_BIN
	)

	i2bin = [i=>convert(S,i) for i in 1:(length(binedges)-1)]

	BinMap(i2bin, binedges,		
		force_outliers_to_closest=force_outliers_to_closest, 
		zero_bin=zero_bin)
end

function encode{T,S}(bmap::BinMap{T,S}, x::T)
	if x < bmap.binedges[1]
		return bmap.force_outliers_to_closest ? bmap.i2bin[1] : throw(BoundsError())
	elseif x > bmap.binedges[end]
		return bmap.force_outliers_to_closest ? bmap.i2bin[bmap.nbins] : throw(BoundsError())
	else
		ind = findfirst(e->x < e, bmap.binedges)
		ind = ind == 0 ? bmap.nbins : ind - 1
		return bmap.i2bin[ind]
	end
end
encode{T,S}(bmap::BinMap{T,S}, x) = encode(bmap, convert(T,x))::S
encode{T,S}(bmap::BinMap{T,S}, data::AbstractArray{T}) = 
	reshape(S[encode(bmap, x) for x in data], size(data))
encode{T,S}(bmap::BinMap{T,S}, data::DataArray{T}) =
	reshape(S[encode(bmap, x) for x in data], size(data))

function decode{T,S}(bmap::BinMap{T,S}, x::S)
	ind = bmap.bin2i[x]
	lo  = bmap.binedges[ind]
	hi  = bmap.binedges[ind+1]

	if bmap.zero_bin && lo <= 0 <= hi
		0.0
	else
		rand(T)*(hi-lo) + lo
	end
end
decode{T,S}(bmap::BinMap{T,S}, x) = decode(bmap, convert(S,x))::T
decode{T,S}(bmap::BinMap{T,S}, data::AbstractArray{S}) = 
	reshape(T[decode(bmap, x) for x in data], size(data))
decode{T,S}(bmap::BinMap{T,S}, data::DataArray{S}) = 
	reshape(T[decode(bmap, x) for x in data], size(data))

nlabels(bmap::BinMap) = bmap.nbins