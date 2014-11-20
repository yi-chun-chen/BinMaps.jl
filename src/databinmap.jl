immutable DataBinMap <: AbstractBinMap
	binedges :: Vector{Float64}
	force_outliers_to_closest :: Bool # if true, real values outside of the bin ranges will be forced to the nearest bin, otherwise will throw an error
end
DataBinMap{S <: Real}(binedges::Vector{S}, force_outliers_to_closest :: Bool = true) = begin 
	@assert(!isempty(binedges))
	@assert(isempty(find(i->binedges[i]>=binedges[i+1], [1:length(binedges)-1])))
	DataBinMap(convert(Vector{Float64}, binedges), force_outliers_to_closest)
end
function databinmap(data::Vector{Float64}, nbins::Integer, force_outliers_to_closest::Bool=true)
	disc_arr, bin_edge_arr = discretize( data, nbins )
	DataBinMap(bin_edge_arr, force_outliers_to_closest)
end
function databinmap(
	data::DataVector{Float64}, 
	nbins::Integer, 
	alg::Cint = DSL_DISCRETIZE_HIERARCHICAL,
	force_outliers_to_closest::Bool=true
	)
	@assert(nbins > 1)
	disc_arr, bin_edge_arr = discretize( dropna(data), nbins-1, algorithm=alg )
	DataBinMap(bin_edge_arr, force_outliers_to_closest)
end
function databinmap_return(
	data::DataVector{Float64}, 
	nbins::Integer,
	alg::Cint = DSL_DISCRETIZE_HIERARCHICAL,
	force_outliers_to_closest::Bool=true
	)
	@assert(nbins > 2)
	disc_arr, bin_edge_arr = discretize( dropna(data), nbins-1, algorithm=alg )
	n = length(data)
	disc_arr2 = zeros(Int32, n)
	c = 1
	for (i,v) in enumerate(data)
		if isa(v, NAtype)
			disc_arr2[i] = nbins-1
		else
			disc_arr2[i] = disc_arr[c]
			c += 1
		end
	end

	(DataBinMap(bin_edge_arr, force_outliers_to_closest), disc_arr2)
end
function discretize(dbmap::DataBinMap, x::Real)

	if x < dbmap.binedges[1]
		dbmap.force_outliers_to_closest ? uint8(1) : throw(BoundsError())
	elseif x > dbmap.binedges[end]
		dbmap.force_outliers_to_closest ? uint8(length(dbmap.binedges)-1) : throw(BoundsError())
	else
		ind = findfirst(e->x < e, dbmap.binedges)
		ind = ind == 0 ? length(dbmap.binedges)-1 : ind - 1
		uint8(ind)
	end
end
discretize(dbmap::DataBinMap, x::NAtype) = length(dbmap.binedges)
discretize(dbmap::DataBinMap, data::Vector{Float64}) =
	reshape(Uint8[discretize(dbmap, x) for x in data], size(data))
discretize(dbmap::DataBinMap, data::DataVector{Float64}) =
	reshape(Uint8[discretize(dbmap, x) for x in data], size(data))
function debin(dbmap::DataBinMap, y::Uint8)
	y <= length(dbmap.binedges) || throw(BoundsError())

	if y == length(dbmap.binedges)
		return NA
	end

	lo = dbmap.binedges[y]
	hi = dbmap.binedges[y+1]
	rand()*(hi-lo) + lo
end
function debin(dbmap::DataBinMap, ys::Vector{Uint8})
	arr = DataArray(Float64, length(ys))
	E = length(dbmap.binedges)
	for (i,y) in enumerate(ys)
		if y != E
			arr[i] = debin(dbmap, y)
		end
	end
	arr
end
length(dbmap::DataBinMap) = length(dbmap.binedges)
supportsna(::DataBinMap) = true
