using NoahYixiaoHashCode
using Documenter

DocMeta.setdocmeta!(NoahYixiaoHashCode, :DocTestSetup, :(using NoahYixiaoHashCode); recursive=true)

makedocs(;
    modules=[NoahYixiaoHashCode],
    authors="nmorale5 <nmorale5@mit.edu> and contributors",
    repo="https://github.com/nmorale5/NoahYixiaoHashCode.jl/blob/{commit}{path}#{line}",
    sitename="NoahYixiaoHashCode.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://nmorale5.github.io/NoahYixiaoHashCode.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/nmorale5/NoahYixiaoHashCode.jl",
    devbranch="main",
)
