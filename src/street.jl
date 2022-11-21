struct Street{L <: Integer,T <: Integer}
    distance::L
    time_cost::T
end

@inline function time_cost(s::Street)
    return s.time_cost
end

@inline function distance(s::Street)
    return s.distance
end

