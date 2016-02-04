__precompile__()

module JsonCall

using FunctionalData, JSON, HttpServer, Requests, HDF5

export jsoncall, jsonhandler, serve, savehdf5, loadhdf5

const HDF5EXT = ".hdf5"
const SINGLEVARIABLE = "jsoncall_singlevariable"

######################
##  parsejson

function parsejson(a::AbstractString)
    r = JSON.parse(a)
    @p parsejson_ r
end

parsejson_(a) = a

function parsejson_(a::AbstractString)
    r = endswith(a, HDF5EXT) ? loadhdf5(a) : a
end

function parsejson_(a::Dict)
    if length(collect(keys(a))) == 2 && haskey(a, "arraysize") && haskey(a,"arraydata")
        return typed(reshape(a["arraydata"], a["arraysize"]...))
    else
        @p mapvalues a parsejson_
    end
end


######################
##  makejson

makejson(a) = JSON.json(makejson_(a))
makejson_(a) = a
makejson_(a::Array) = try makejson_(typed(a)) catch a end
function makejson_{T<:Number,N}(a::Array{T,N})
    Dict("arraysize" => size(a), "arraydata" => vec(a))
end
makejson_(a::Dict) = @p mapvalues a makejson_


######################
##  jsonhandler

function jsonhandler(f)
    jsonhandler = HttpHandler() do req::Request, res::Response
        d = parsejson(ascii(req.data))
        r = f(d)
        Response(makejson(r))
    end
end


######################
##  jsoncall

function jsoncall(d::Dict, port = 8000, url = "http://localhost:$port")
    r = readall(post("http://localhost:$port"; data = makejson(d)))
    parsejson(r)
end


######################
##  jsoncall

serve(f, port = 8000) = @async @p jsonhandler f | Server | run port


######################
##  savehdf5

savehdf5(filename, data) = savehdf5(filename, Dict(SINGLEVARIABLE => data))
function savehdf5(filename, data::Dict)
    endswith(filename, HDF5EXT) || error("JsonCall: Filename must end in '$HDF5EXT'")
    h5open(filename, "w") do file
        for key in keys(data)
            write(file, key, data[key])
        end
    end
    filename
end

######################
##  loadhdf5

function loadhdf5(filename)
    d = Dict()
    h5open(filename, "r") do file
        for key in names(file)
            d[key] = read(file, key)
        end
    end
    isa(d, Dict) && haskey(d, SINGLEVARIABLE) ? d[SINGLEVARIABLE] : d
end

end # module





