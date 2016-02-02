println("\n\n\nStarting runtests.jl $(join(ARGS, " ")) ...")
using JsonCall, FactCheck, FunctionalData

facts("makejson") do
    for a in Any[
        1, "test", Dict("a" => "b"), 
        Dict("test" => Dict("a" => "b", "c" => zeros(2,3))),
        zeros(2,3,4,5)
        ]
        @fact JsonCall.parsejson(JsonCall.makejson(a)) --> a
    end
end

function myfunc(d::Dict)
    Dict("usage" => "please call me like this",
    "got" => d)
end

facts("call") do
    serve(myfunc)
    println("posting ...")
    d = Dict("id" => "123", "data" => zeros(2,3))
    a = jsoncall(d)
    @fact a --> Dict{Any,Any}("usage"=>"please call me like this","got"=>Dict{Any,Any}("id"=>"123","data"=>[0.0 0.0 0.0; 0.0 0.0 0.0]))
end


