# AlgebraicMetabolism.jl

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://AlgebraicJulia.github.io/AlgebraicMetabolism.jl/stable)
[![Development Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://AlgebraicJulia.github.io/AlgebraicMetabolism.jl/dev)
[![Code Coverage](https://codecov.io/gh/AlgebraicJulia/AlgebraicMetabolism.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/AlgebraicJulia/AlgebraicMetabolisme.jl)
[![CI/CD](https://github.com/AlgebraicJulia/AlgebraicMetabolism.jl/actions/workflows/julia_ci.yml/badge.svg)](https://github.com/AlgebraicJulia/AlgebraicMetabolism.jl/actions/workflows/julia_ci.yml)

A package for doing metabolic networks or biochemical systems theory in AlgebraicJulia.

### 🛡️ Set Up Branch Protection (once we have multiple contributors)

1. Follow the Usage steps above to set up a new template, make sure all initial GitHub Actions have passed
2. Navigate to the repository settings and go to "Code and automation", "Branches"
3. Click "Add branch protection rule" to start adding branch protection
4. Under "Branch name pattern" put `main`, this will add protection to the main branch
5. Make sure to set the following options:
   - Check the "Require a pull request before merging"
   - Check the "Request status checks to pass before merging" and make sure the following status checks are added to the required list:
     - CI / Documentation
     - CI / Julia 1 - ubuntu-latest - x64 - push
     - CI / Julia 1 - ubuntu-latest - x86 - push
     - CI / Julia 1 - windows-latest - x64 - push
     - CI / Julia 1 - windows-latest - x86 - push
     - CI / Julia 1 - macOS-latest - x64 - push
   - Check the "Restrict who can push to matching branches" and add `algebraicjuliabot` to the list of people with push access
6. Click "Save changes" to enable the branch protection
