# Author: Josh Day <emailjoshday@gmail.com>

export OnlineFitExponential

#------------------------------------------------------------------------------#
#---------------------------------------------------# OnlineFitExponential Type
type OnlineFitExponential <: ContinuousUnivariateOnlineStat
    d::Distributions.Exponential
    stats::Distributions.ExponentialStats

    n::Int64
    nb::Int64
end

function onlinefit{T<:Real}(::Type{Exponential}, y::Vector{T})
    n::Int64 = length(y)
    OnlineFitExponential(fit(Exponential, y), suffstats(Exponential, y), n, 1)
end


#------------------------------------------------------------------------------#
#---------------------------------------------------------------------# update!
function update!(obj::OnlineFitExponential, newdata::Vector)
    newstats = suffstats(Exponential, newdata)
    n1 = obj.stats.sw
    n2 = newstats.sw
    n = n1 + n2

    sx = obj.stats.sx + newstats.sx

    obj.stats = Distributions.ExponentialStats(sx, n)
    obj.d = fit_mle(Exponential, obj.stats)
    obj.n = n
    obj.nb += 1
end


#------------------------------------------------------------------------------#
#-----------------------------------------------------------------------# state
function state(obj::OnlineFitExponential)
    names = [:β, :n, :nb]
    estimates = [obj.d.β, obj.n, obj.nb]
    return([names estimates])
end



#------------------------------------------------------------------------------#
#---------------------------------------------------------# Interactive Testing
# x1 = rand(Exponential(4), 100)
# obj = OnlineStats.onlinefit(Exponential, x1)
# OnlineStats.state(obj)

# x2 = rand(Exponential(4), 100)
# OnlineStats.update!(obj, x2)
# OnlineStats.state(obj)
