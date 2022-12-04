"""
    Street

Store the information of a street.

# Fields
- `distance::D`: length
- `time_cost::T`: time cost
- `j₀::A` : index of first junction
- `j₁::B` : index of second junction
"""
struct Street{D<:Integer,T<:Integer,A<:Integer,B<:Integer}
    distance::D
    time_cost::T
    j₀::A
    j₁::B
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
