using Javis

function ground(args...)
    background("black")
    sethue("white")
end

function armObject(video, object, frame, frames, tp, C)
    arm = tp(comptopoint.(fourierArm(frame / frames, C)))
    for i in 1:length(arm) - 1
        setline(2)
        line(arm[i], arm[i + 1], :stroke)
    end
end

function drawing(video, object, frame, points, frames)
    for i in 1:trunc(Int, frame / frames * length(points)) - 1
        setline(2)
        line(points[i], points[i + 1], :stroke)
    end
end

comptopoint(z) = Point(real(z), imag(z))

"""
Render an animation of a Fourier series drawing and save it to `savePath`.

By default, resolution is 1080p. If only one dimension is specified, the other will be calculated to be in proportion with the drawing.

`n_drawing` defines the number of points used in graphing the drawing. By default, it is equal to the number of frames (1 point for each frame).
"""
function createVideo(coefficients, savePath, frames; width = nothing, height = nothing, n_drawing = frames, fps = 60)
    f = t -> fourierSeries(t, coefficients)
    t_array = range(0, 1, length=n_drawing)

    test_points = f.(t_array)
    x_max = maximum(real(test_points))
    x_min = minimum(real(test_points))
    y_max = maximum(imag(test_points))
    y_min = minimum(imag(test_points))
    x_dif = x_max - x_min
    y_dif = y_max - y_min

    if width === nothing && height === nothing

        if 16/x_dif >= 9/y_dif
            scale = 1080/y_dif
            height = 1080
            width = ((x_dif * scale) ÷ 2) * 2
        else
            scale = 1920 / x_dif
            width = 1920
            height = ((y_dif * scale) ÷ 2) * 2
        end
    elseif width === nothing
        scale = height / y_dif
        width = ((x_dif * scale) ÷ 2) * 2
    elseif height === nothing
        scale = width / x_dif
        height = ((y_dif * scale) ÷ 2) * 2
    else
        scale = width / x_dif >= height / y_dif ? height / y_dif : width / x_dif
    end

    transformPoints(points) = (((points .- Point(x_min, y_min)) .* Point(scale, -scale)) .+ Point(-x_dif * scale / 2, y_dif * scale / 2)) .* 0.9
    drawing_points = transformPoints(map(i -> comptopoint(f(i)), t_array))

    myvideo = Video(round(Int, width), round(Int, height))
    Background(1:frames, ground)

    Object(1:frames, (args...) -> armObject(args..., frames, transformPoints, coefficients))
    Object(1:frames, (args...) -> drawing(args..., drawing_points, frames))

    render(myvideo; pathname = savePath, framerate=fps)
end