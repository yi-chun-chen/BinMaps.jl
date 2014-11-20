# DataBinMap
#  maps continuous values to bins, supports NA
#  encoding a value will return the item associated with that bin
#  decoding a bin will sample uniformally from that bin

immutable DataBinMap{T<:FloatingPoint,S} <: AbstractBinMap{T,S}
	i2bin    :: Dict{Int,S}
	bin2i    :: Dict{S,Int}
	binedges :: Vector{T}
	nbins    :: Int # NA is assigned to i2bin[nbins]
	force_outliers_to_closest :: Bool # if true, real values outside of the bin ranges will be forced to the nearest bin, otherwise will throw an error
end

function DataBinMap{T<:FloatingPoint, S}(
	i2bin    :: Dict{Int,S}, 
	binedges :: Vector{T}, 
	force_outliers_to_closest::Bool = BINMAP_DEFAULT_OUTLIER_FORCE
	)

	length(binedges) > 1 || error("Bin edges must contain at least 2 values")
    findfirst(i->binedges[i+1]<=binedges[i], [1:length(binedges)-1]) == 0 || 
    	error("Bin edges must be sorted in increasing order")

    bin2i = Dict{S,Int}()
	for (k,v) in i2bin
		bin2i[v] = k
	end
	
	DataBinMap{T,S}(i2bin, bin2i, binedges, length(i2bin), force_outliers_to_closest)
end
function databinmap{T<:FloatingPoint, S<:Integer}(
	data  :: AbstractArray{T},
	nbins :: Integer,
	      :: Type{S},
	alg   :: DiscretizatonAlgorithm = DISCRETIZE_UNIFORMWIDTH;
	force_outliers_to_closest::Bool = BINMAP_DEFAULT_OUTLIER_FORCE
	)

	nbins > 1 || error("must have at least 2 bins to support NA")

	i2bin = [i=>convert(S,i) for i in 1:nbins]
	bin_edges = binedges(alg, nbins-1, data)

	DataBinMap(i2bin, bin_edges, force_outliers_to_closest)
end
function databinmap{T<:FloatingPoint, S<:Integer}(
	data  :: DataArray{T},
	nbins :: Integer,
	      :: Type{S},
	alg   :: DiscretizatonAlgorithm = DISCRETIZE_UNIFORMWIDTH;
	force_outliers_to_closest::Bool = BINMAP_DEFAULT_OUTLIER_FORCE
	)

	nbins > 1 || error("must have at least 2 bins to support NA")

	i2bin = [i=>convert(S,i) for i in 1:nbins]

	arr = dropna(data)
	!isempty(arr) || error("must contain at least one non-NA value!")

	bin_edges = binedges(alg, nbins-1, arr)

	DataBinMap(i2bin, bin_edges, force_outliers_to_closest)
end

function encode{T,S}(bmap::DataBinMap{T,S}, x::T)
	if x < bmap.binedges[1]
		return bmap.force_outliers_to_closest ? bmap.i2bin[1] : throw(BoundsError())
	elseif x > bmap.binedges[end]
		return bmap.force_outliers_to_closest ? bmap.i2bin[bmap.nbins-1] : throw(BoundsError())
	else
		ind = findfirst(e->x < e, bmap.binedges)
		ind = ind == 0 ? bmap.nbins-1 : ind-1
		return bmap.i2bin[ind]
	end
end
encode{T,S}(bmap::DataBinMap{T,S}, x::NAtype) = bmap.i2bin[bmap.nbins]
encode{T,S}(bmap::DataBinMap{T,S}, x) = encode(bmap, convert(T,x))::S
encode{T,S}(bmap::DataBinMap{T,S}, data::AbstractArray{T}) = 
	reshape(S[encode(bmap, x) for x in data], size(data))
encode{T,S}(bmap::DataBinMap{T,S}, data::DataArray{T}) =
	reshape(S[encode(bmap, x) for x in data], size(data))

function decode{T,S}(bmap::DataBinMap{T,S}, x::S)
	ind = bmap.bin2i[x]
	if ind == bmap.nbins
		return NA
	end
	lo  = bmap.binedges[ind]
	hi  = bmap.binedges[ind+1]
	rand(T)*(hi-lo) + lo
end
decode{T,S}(bmap::DataBinMap{T,S}, x) = decode(bmap, convert(S,x))::T
decode{T,S}(bmap::DataBinMap{T,S}, data::AbstractArray{S}) = 
	reshape(T[decode(bmap, x) for x in data], size(data))
decode{T,S}(bmap::DataBinMap{T,S}, data::DataArray{S}) = 
	reshape(T[decode(bmap, x) for x in data], size(data))

nlabels(bmap::DataBinMap) = bmap.nbins

supports_encoding{T,S}(::DataBinMap{T,S}, typ::Type) = typ <: T || typ <: NAtype
supports_encoding{T,S}(::DataBinMap{T,S}, x) = isa(x, T) || isa(x, NAtype)