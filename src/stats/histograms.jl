# TODO: Box 2 in https://www.cse.wustl.edu/~jain/papers/ftp/psqr.pdf

#-----------------------------------------------------------------------# 


#-----------------------------------------------------------------------# 
mutable struct NextHist{T <: Range} <: ExactStat{0}
    value::Vector{Int}
    x::T 
    n::Int
end
NextHist(b::Integer) = NextHist(zeros(Int, b), linspace(0, 0, b), 0)

function fit!(o::NextHist, y::Real, γ::Float64)
    x = o.x
    o.n += 1
    if o.n == 1
        o.x = linspace(y, y, length(x))
    end
    a, b = extrema(x)
    if y < a
        o.x = linspace(y, b, length(x))
        o.value[1] += 1
    elseif y > b
        o.x = linspace(a, y, length(x))
        o.value[end] += 1
    elseif o.n > 1
        if o.n > 1
            δ = step(x)
            k = floor(Int, (y - a) / δ) + 1
            if 1 <= k <= length(x)
                @inbounds o.value[k] += 1
            end
        end
    end
end

#-----------------------------------------------------------------------# Histogram2 
struct Histogram2 <: ExactStat{0}
    value::Vector{Float64}
    counts::Vector{Int}
end

#-----------------------------------------------------------------------# IHistogram
# http://www.jmlr.org/papers/volume11/ben-haim10a/ben-haim10a.pdf
"""
    IHistogram(b)

Incrementally build a histogram of `b` (not equally spaced) bins.  An `IHistogram` can be
used as a "surrogate" for a dataset to get approximate summary statistics.

# Example

    o = IHistogram(50)
    Series(randn(1000), o)

    # approximate summary stats
    quantile(o)
    mean(o)
    var(o)
    std(o)
    extrema(o)
    median(o)
"""
mutable struct IHistogram <: ExactStat{0}
    value::Vector{Float64}
    counts::Vector{Int}
    n::Int
end
IHistogram(b::Integer) = IHistogram(fill(Inf, b), zeros(Int, b), 0)


fit!(o::IHistogram, y::Real, γ::Float64) = push!(o, Pair(y, 1))

function Base.push!(o::IHistogram, p::Pair)
    o.n += last(p)
    i = searchsortedfirst(o.value, first(p))
    insert!(o.value, i, first(p))
    insert!(o.counts, i, last(p))
    ind = find_min_diff(o)
    binmerge!(o, ind)
end

function binmerge!(o::IHistogram, i)
    k2 = o.counts[i+1]
    if k2 != 0
        k1 = o.counts[i]
        q1 = o.value[i]
        q2 = o.value[i + 1]
        o.value[i] = smooth(q1, q2, k2 / (k1 + k2))
        o.counts[i] += k2
    end
    deleteat!(o.value, i + 1)
    deleteat!(o.counts, i + 1)
end

function find_min_diff(o)
    v = o.value
    o.n < length(v) && return o.n
    ind = 0
    mindiff = Inf
    for i in 1:(length(v) - 1)
        @inbounds diff = v[i + 1] - v[i]
        if diff < mindiff 
            mindiff = diff 
            ind = i
        end
    end
    ind
end

function Base.merge!(o::IHistogram, o2::IHistogram, γ::Float64)
    for p in Pair.(o2.value, o2.counts)
        push!(o, p)
    end
end

# Algorithm 3: Sum Procedure
# Estimated number of points in interval [-∞, b]
function Base.sum(o::IHistogram, b::Real)
    i = searchsortedfirst(o.value, b)
    m1 = o.counts[i]
    m2 = o.counts[i + 1]
    p1 = o.value[i]
    p2 = o.value[i + 1]
    mb = m1 + (m2 - m1) * (b - p1) / (p2 - p1)
    s = .5 * (m1 + mb) * (b - p1) / (p2 - p1)
    return s + sum(o.counts[1:(i-1)]) + m1 / 2
end

# Algorithm 4: Uniform Procedure (locations of candidate splits)
function uniform(o::IHistogram, B::Integer)
    m = sum(o.counts) / B
    cs = cumsum(o.counts)
    u = Vector{Float64}(B-1)
    for j in 1:(B-1)
        s = j * m
        i = searchsortedfirst(cs, s)
        d = s - cs[i]
        m1 = o.counts[i]
        m2 = o.counts[i + 1]
        p1 = o.value[i]
        p2 = o.value[i + 1]
        a = m2 - m1
        b = 2m1
        c = -2d
        z = (-b + sqrt(b^2 - 4*a*c)) / (2a)
        u[j] = p1 + (p2 - p1) * z
    end
    u
end

#-----------------------------------------------------------------------# summaries
Base.extrema(o::IHistogram) = (first(o.value), last(o.value))
Base.mean(o::IHistogram) = mean(o.value, fweights(o.counts))
Base.var(o::IHistogram) = var(o.value, fweights(o.counts); corrected=true)
Base.std(o::IHistogram) = sqrt(var(o))
function Base.quantile(o::IHistogram, p = [0, .25, .5, .75, 1]) 
    inds = find(o.counts)  # filter out zero weight bins
    quantile(o.value[inds], fweights(o.counts[inds]), p)
end
Base.median(o::IHistogram) = quantile(o, .5)

function discretized_pdf(o::IHistogram, y::Real)
    i = searchsortedfirst(o.value, y)
    if i > length(o.counts)
        i -= 1
    end
    o.counts[i] / sum(o.counts)
end

#-----------------------------------------------------------------------# OHistogram
"""
    OHistogram(range)

Make a histogram with bins given by `range`.  Uses left-closed bins.  `OHistogram` fits
faster than [`IHistogram`](@ref), but has the disadvantage of requiring specification of
bins before data is observed.

# Example

    y = randn(100)
    o = OHistogram(-5:.01:5)
    s = Series(y, o)
    
    value(o)  # return StatsBase.Histogram
    quantile(o)
    mean(o)
    var(o)
    std(o)
"""
struct OHistogram{H <: Histogram} <: ExactStat{0}
    h::H
end
OHistogram(r::Range) = OHistogram(Histogram(r, :left))
function fit!(o::OHistogram, y::ScalarOb, γ::Float64)
    H = o.h
    x = H.edges[1]
    a = first(x)
    δ = step(x)
    k = floor(Int, (y - a) / δ) + 1
    if 1 <= k <= length(x)
        @inbounds H.weights[k] += 1
    end
end
Base.merge!(o::T, o2::T, γ::Float64) where {T <: OHistogram} = merge!(o.h, o2.h)

_x(o::OHistogram) = (o.h.edges[1] + .5*step(o.h.edges[1]))[2:end]

Base.mean(o::OHistogram) = mean(_x(o), fweights(o.h.weights))
Base.var(o::OHistogram) = var(_x(o), fweights(o.h.weights); corrected=true)
Base.std(o::OHistogram) = sqrt(var(o))

function Base.quantile(o::OHistogram, p = [0, .25, .5, .75, 1]) 
    inds = find(o.h.weights)  # filter out zero weights
    quantile(_x(o)[inds], fweights(o.h.weights[inds]), p)
end