# LabelMap
#   maps discrete labels to discrete values

immutable LabelMap{T,S} <: AbstractBinMap{T,S}
	v2i :: Dict{T,S} # maps labels to indeces
	i2v :: Dict{S,T} # maps indeces to labels
end

function LabelMap{T,S}(v2i::Dict{T,S})
	i2v = Dict{S,T}()
	for (k,v) in v2i
		i2v[v] = k
	end
	LabelMap{T,S}(v2i, i2v)
end
function labelmap{T, S<:Integer}(data::AbstractArray{T}, ::Type{S})
	# build a labebmap mapping T -> S <: Integer
	i = zero(S)
	v2i = (T=>S)[]
	for x in data
		if !haskey(v2i,x)
			v2i[x] = (i += 1)
		end
	end
	LabelMap(v2i)
end

encode{T,S}(bmap::LabelMap{T,S}, x::T) = bmap.v2i[x]::S
encode{T,S}(bmap::LabelMap{T,S}, x)    = bmap.v2i[convert(T,x)]::S
encode{T,S}(bmap::LabelMap{T,S}, data::AbstractArray{T}) = 
	reshape(S[encode(bmap, x) for x in data], size(data))
encode{T,S}(bmap::LabelMap{T,S}, data::DataArray{T}) =
	reshape(S[encode(bmap, x) for x in data], size(data))

decode{T,S}(bmap::LabelMap{T,S}, x::S) = bmap.i2v[x]::T
decode{T,S}(bmap::LabelMap{T,S}, x)    = bmap.i2v[convert(S,x)]::T
decode{T,S}(bmap::LabelMap{T,S}, data::AbstractArray{S}) = 
	reshape(T[decode(bmap, x) for x in data], size(data))
decode{T,S}(bmap::LabelMap{T,S}, data::DataArray{S}) = 
	reshape(T[decode(bmap, x) for x in data], size(data))

nlabels(bmap::LabelMap) = length(bmap.v2i)