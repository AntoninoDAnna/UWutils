function ADerrors.addobs(a::AbstractVector{uwreal}, der::AbstractVector{Float64}, mvl::Float64)
    n = 0
    for i in 1:length(a)
        n = max(n,length(a[i].der))
    end
    p = [false for i in 1:n]
    d = zeros(Float64, n)

    for k in 1:n
        for j in 1:length(a)
            if (k <= length(a[j].prop))
                p[k] = p[k] || a[j].prop[k]
                if (a[j].prop[k])
                    d[k] = d[k] + der[j]*a[j].der[k]
                end
            end
        end
    end

    return uwreal(mvl, p, d)
end


function ADerrors.addobs(a::AbstractVector{uwreal}, der::AbstractArray{Float64, 2}, mvl::AbstractVector{Float64})
    n = 0
    for i in 1:length(a)
        n = max(n,length(a[i].der))
    end

    x = Vector{uwreal}(undef, size(der, 1))
    for i in 1:size(der, 1)
        p = [false for i in 1:n]
        d = zeros(Float64, n)
        for k in 1:n
            for j in 1:length(a)
                if (k <= length(a[j].prop))
                    p[k] = p[k] || a[j].prop[k]
                    if (a[j].prop[k])
                        d[k] = d[k] + der[i,j]*a[j].der[k]
                    end
                end
            end
        end
        x[i] = uwreal(mvl[i], p, d)
    end

    return x
end
