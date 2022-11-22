"""
    Street

Store the information of a street.

# Fields
- `distance::D`: length
- `time_cost::T`: time cost
"""
struct Street{D<:Integer,T<:Integer}
    distance::D
    time_cost::T
end

"""
    time_cost(street)

Return the time cost of traversing a [`Street`](@ref).
"""
@inline function time_cost(s::Street)
    return s.time_cost
end

"""
    distance(street)

Return the length of a [`Street`](@ref).
"""
@inline function distance(s::Street)
    return s.distance
end
