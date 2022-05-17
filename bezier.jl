using EzXML

"""
Get a complex parametric function for a series of cubic bezier curves as described in an .svg file. See README for details on file requirements.
"""
function createCurve(fileName)
    doc = readxml(pwd() * "/" * fileName)

    svg = root(doc)

    layers = []
    paths = []

    for element in eachelement(svg)
        occursin("layer", element["id"]) && push!(layers, element)
    end

    for element in eachelement(layers[1])
        occursin("path", element["id"]) && push!(paths, element)
    end

    pointPattern = r"(?<=c ).*"
    curveString = match(pointPattern, paths[1]["d"]).match
    
    pattern = r"((?:-)?\d*(?:\.\d*)?),((?:-)?\d*(?:\.\d*)?)"
    m = collect(eachmatch(pattern, curveString))

    b_input = [[0.0,0.0]]

    for i in m
        k = length(b_input)
        Δx = parse(Float64, i[1])
        Δy = -parse(Float64, i[2])
        new_point = [b_input[k-(k-1)%3][1] + Δx, b_input[k-(k-1)%3][2] + Δy]

        push!(b_input, new_point)
    end

    return t -> parametricBezier(t, b_input)
end

"""
Parametric function for a curve made up of cubic bezier curves described by a vector of complex coordinates `input`.

Format for points taken from svg format.
"""
function parametricBezier(t, input)
    t = t%1
    n_input = length(input)-1
    n_cubics = n_input÷3

    cubicIndex = convert(Int, t÷(1//n_cubics)+1)
    cubicTime = (t%(1/n_cubics))*n_cubics
    currentCubic = input[3(cubicIndex-1)+1:3cubicIndex+1]
    b_t = b(cubicTime, currentCubic)

    return b_t[1] + b_t[2]*im
end

"""
Get position along bezier curve described by points `p` at time `t` from 0 to 1.
"""
function b(t, p)
    s = [0,0]

    for i in 1:length(p)
        s += B(length(p)-1,i-1,t) * p[i]
    end

    return s
end

"Bernstein polynomial"
function B(n_p,i,t)
    binomial(n_p,i)*t^i*(1-t)^(n_p-i)
end