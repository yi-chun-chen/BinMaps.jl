
immutable DataLabelMap{T,S<:Integer} <: AbstractBinMap{T,S}
	v2i :: Dict{T,S} # maps labels to indeces
	i2v :: Dict{S,T} # maps indeces to labels
	nai :: S         # index assigned to NA = length(v2i)+1
end

function DataLabelMap{T,S<:Integer}(v2i::Dict{T,S})
	i2v = Dict{S,T}()
	for (k,v) in v2i
		i2v[v] = k
	end
	DataLabelMap{T,S}(v2i, i2v, convert(S, length(v2i)+1))
end
function datalabelmap{T,S<:Integer}(data::AbstractArray{T}, ::Type{S})
	# build a labelmap mapping T -> S <: Integer
	i = zero(S)
	v2i = (T=>S)[]
	for x in data
		if !haskey(v2i,x)
			v2i[x] = (i += 1)
		end
	end
	DataLabelMap(v2i)
end
function datalabelmap{T,S<:Integer}(data::DataVector{T}, ::Type{S})
	# build a labelmap mapping T -> S <: Integer
	i = zero(S)
	v2i = (T=>S)[]
	for x in data
		if !isa(x, NAtype) && !haskey(v2i,x)
			v2i[x] = (i += 1)
		end
	end
	DataLabelMap(v2i)
end

encode{T,S}(bmap::DataLabelMap{T,S}, x::T     ) = bmap.v2i[x]::S
encode{T,S}(bmap::DataLabelMap{T,S}, x::NAtype) = bmap.nai::S
encode{T,S}(bmap::DataLabelMap{T,S}, x        ) = bmap.v2i[convert(T,x)]::S

encode{T,S}(bmap::DataLabelMap{T,S}, data::AbstractArray{T}) = 
	reshape(S[encode(bmap, x) for x in data], size(data))
encode{T,S}(bmap::DataLabelMap{T,S}, data::DataVector{T}) =
	reshape(S[encode(bmap, x) for x in data], size(data))

decode{T,S}(bmap::DataLabelMap{T,S}, x::S) = x==bmap.nai ? NA : bmap.i2v[x]
decode{T,S}(bmap::DataLabelMap{T,S}, x)    = bmap.i2v[convert(S,x)]

function decode{T,S}(bmap::DataLabelMap{T,S}, data::AbstractArray{S})
	retval = DataArray(T, length(data))
	for (i,x) in enumerate(data)
		retval[i] = decode(bmap, x)
	end
	reshape(retval, size(data))
end
function decode{T,S}(bmap::DataLabelMap{T,S}, data::DataVector{S})
	retval = DataArray(T, length(data))
	for (i,x) in enumerate(data)
		retval[i] = decode(bmap, x)
	end
	reshape(retval, size(data))
end

nlabels(bmap::DataLabelMap) = length(bmap.v2i) + 1

supports_encoding{T,S}(::DataLabelMap{T,S}, typ::Type) = typ <: T || typ <: NAtype
supports_encoding{T,S}(::DataLabelMap{T,S}, x) = isa(x, T) || isa(x, NAtype)