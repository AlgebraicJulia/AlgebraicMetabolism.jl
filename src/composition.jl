export OpenMetabolicNetOb, OpenMetabolicNet

const OpenMetabolicNetOb, OpenMetabolicNet = OpenACSetTypes(MetabolicNet, :V)

# Open networks with numeric parameters
const OpenReactionNetObUntyped, OpenReactionNetUntyped = OpenACSetTypes(ReactionNetUntyped, :V)

# Fix the default Name type to Symbol
const OpenReactionNetOb{R} = OpenReactionNetObUntyped{Symbol, R}
const OpenReactionNet{R} = OpenReactionNetUntyped{Symbol, R}

