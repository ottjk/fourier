"""
Simpson's rule integration on function `f` with bounds `a` to `b` with `n` intervals.
"""
function integrate(f, a, b, n)
    h = (b-a)/2n
    x(k) = a + k*h
    y(k) = f(x(k))

    s = y(0) + y(2n)
    for i in 1:2n-1
        i % 2 == 1 ? s += 4y(i) : s += 2y(i)
    end

    I = h/3*s
    return I
end

"""
Calculate Fourier coefficient for term with frequency `n` of function `f`.
"""
function c(f, n)
    g(t)=f(t)*exp(-2π*im*n*t)
    integrate(g,0,1,500)
end

"""
Calculate `n` coefficients for the terms in the fourier series approximation of a given function `f(t)` over domain [0,1].

Corresponding frequencies for the coefficients are 0, 1, -1, 2, -2, and so on.
"""
function calculateCoefficients(f, n)
    coefficients = zeros(Complex{Float64}, n)
    coefficients[1] = c(f, 0)

    Threads.@threads for i in 2:n
        coefficients[i] = c(f, (i÷2)*(-1)^i)
    end

    return coefficients
end

"""
Calculate Fourier series at time `t` with `coefficients` as given by `calculateCoefficients`.
"""
function fourierSeries(t, coefficients)
    z = coefficients[1]
    n = length(coefficients)

    for i in 2:n
        z += coefficients[i]*exp(2π*im*(i÷2)*(-1)^i*t)
    end

    return z
end

"""
Similar to `fourierSeries` but returns a vector of all the intermediate sums. For use in animations.
"""
function fourierArm(t, coefficients)
    n = length(coefficients)
    arm = zeros(Complex{Float64}, n)
    z = 0

    for i in 1:n
        z += coefficients[i] * exp(2π*im*(i÷2)*(-1)^i*t)
        arm[i] = z
    end

    return arm
end
