__precompile__()

module JsonCall

using FunctionalData, JSON, HttpServer, Requests

export jsoncall, jsonhandler, serve


function parsejson(a::AbstractString)
    r = JSON.parse(a)
    @p parsejson_ r
end

parsejson_(a) = a
function parsejson_(a::Dict)
    if length(collect(keys(a))) == 2 && haskey(a, "arraysize") && haskey(a,"arraydata")
        return typed(reshape(a["arraydata"], a["arraysize"]...))
    else
        @p mapvalues a parsejson_
    end
end


makejson(a) = JSON.json(makejson_(a))
makejson_(a) = a
makejson_(a::Array) = try makejson_(typed(a)) catch a end
function makejson_{T<:Number,N}(a::Array{T,N})
    Dict("arraysize" => size(a), "arraydata" => vec(a))
end
makejson_(a::Dict) = @p mapvalues a makejson_


function jsonhandler(f)
    jsonhandler = HttpHandler() do req::Request, res::Response
        d = parsejson(ascii(req.data))
        r = f(d)
        Response(makejson(r))
    end
end


function jsoncall(d::Dict, port = 8000, url = "http://localhost:$port")
    r = readall(post("http://localhost:$port"; data = makejson(d)))
    parsejson(r)
end

serve(f, port = 8000) = @async @p jsonhandler f | Server | run port
end # module
