# includes each junction only once (somehow better)
function get_optimal_points(problem::RoutingProblem)
    # construct a matrix to be used as an argument in kmeans algorithm
    if saved_points === nothing
        points = zeros(2, 2*problem.n_streets)
        for s in 1:problem.n_streets
            street = problem.streets[s]
            points[1, 2s-1] = problem.junctions[street.j₀].lat
            points[2, 2s-1] = problem.junctions[street.j₀].lon
            points[1, 2s] = problem.junctions[street.j₁].lat
            points[2, 2s] = problem.junctions[street.j₁].lon
        end
        global saved_points = points
    end
    # run algorithm
    centers = kmeans(saved_points, 8).centers
    # reconstruct back into a Vector of Junctions
    return [Junction(centers[1, car], centers[2, car]) for car in 1:8]
end

saved_points = nothing

# output after being run once:
preloaded_goals = [
    Junction{Float64}(48.88090187612858, 2.375570531981639)
    Junction{Float64}(48.84874659212851, 2.275704454618472)
    Junction{Float64}(48.88433620407635, 2.334175428533861)
    Junction{Float64}(48.87285834041586, 2.2989562687459455)
    Junction{Float64}(48.839131350232314, 2.3168638837425393)
    Junction{Float64}(48.858654900828, 2.34980190433121)
    Junction{Float64}(48.85158207383003, 2.3957477659195803)
    Junction{Float64}(48.8313376525394, 2.3600754428196167)
]
# includes each junction as many times as it has streets, 
# effectively weighing more frequent junctions more heavily (somehow worse)
# function get_optimal_points(problem::RoutingProblem)
#     # construct a matrix to be used as an argument in kmeans algorithm
#     points = zeros(2, 2*problem.n_streets)
#     for s in 1:problem.n_streets
#         street = problem.streets[s]
#         points[1, 2s-1] = problem.junctions[street.j₀].lat
#         points[2, 2s-1] = problem.junctions[street.j₀].lon
#         points[1, 2s] = problem.junctions[street.j₁].lat
#         points[2, 2s] = problem.junctions[street.j₁].lon
#     end
#     # run algorithm
#     centers = kmeans(points, 8).centers
#     # reconstruct back into a Vector of Junctions
#     return [Junction(centers[1, car], centers[2, car]) for car in 1:8]
# end