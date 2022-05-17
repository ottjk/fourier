cd(@__DIR__)
include("fourier.jl")
include("bezier.jl")
include("animation.jl")

curve = createCurve("graphics/jerma.svg")
C = calculateCoefficients(curve, 250)
createVideo(C, "jerma.gif", 400; width=250, n_drawing=2000, fps=30)