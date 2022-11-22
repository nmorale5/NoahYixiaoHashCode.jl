"""
    Junction

Store the location of a junction.

# Fields
- `lat::N`: latitude
- `lon::N`: longitude
"""
struct Junction{N <: Real}
    lat::N
    lon::N
end
