# NoahYixiaoHashCode

A package to solve the the 2014 Google Hash Code using a greedy algorithm.

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://nmorale5.github.io/NoahYixiaoHashCode.jl/dev/)
[![Build Status](https://github.com/nmorale5/NoahYixiaoHashCode.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/nmorale5/NoahYixiaoHashCode.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/nmorale5/NoahYixiaoHashCode.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/nmorale5/NoahYixiaoHashCode.jl)

## Usage

```julia
using NoahYixiaoHashCode

problem = load_problem()
solution = solve_greedy(problem)
open("solution_NoahYixiaoHashCode.txt", "w") do f
    save_text(solution; io=f)
end
```
