export OpenMetabolicNetOb, OpenMetabolicNet

const OpenMetabolicNetOb, OpenMetabolicNet = OpenACSetTypes(MetabolicNet, :V)

# Open networks with numeric parameters
const OpenSystemObUntyped, OpenSystemUntyped = OpenACSetTypes(SystemUntyped, :V)

# Fix the default Name type to Symbol
const OpenSystemOb{R} = OpenSystemObUntyped{Symbol, R}
const OpenSystem{R} = OpenSystemUntyped{Symbol, R}

