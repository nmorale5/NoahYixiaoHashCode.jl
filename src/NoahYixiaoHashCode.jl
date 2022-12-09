module NoahYixiaoHashCode

import SparseArrays: sparse, rowvals, nzrange
import Clustering: kmeans

export Junction
export Street
export RoutingProblem
export Solution
export is_feasible
export total_distance
export load_problem
export solve_randwalk
export solve_greedy
export solve_astar
export one_trial_astar
export astar_heuristic_class
export test_astar
export get_optimal_points
export average_efficiency
export average_distance
export save_text

include("junction.jl")
include("street.jl")
include("routing_problem.jl")
include("solution.jl")
include("solver_randwalk.jl")
include("solver_greedy.jl")
include("solver_astar.jl")
include("kmeans.jl")
include("averages.jl")
include("best_random.jl")
end
