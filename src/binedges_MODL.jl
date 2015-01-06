export DISCRETIZE_MODL_OPTIMAL

immutable Discretize_MODL_Optimal <: DiscretizatonAlgorithm end
const DISCRETIZE_MODL_OPTIMAL = Discretize_MODL_Optimal()

function binedges{T<:FloatingPoint, S<:Integer}(
	                :: Discretize_MODL_Optimal, 
	continuous      :: AbstractArray{T}, 
	discrete_target :: AbstractArray{S}
	)

	@assert(length(continuous) == length(discrete_target))
	
	# finish implementing here
end