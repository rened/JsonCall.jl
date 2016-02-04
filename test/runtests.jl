println("\n\n\nStarting runtests.jl $(join(ARGS, " ")) ...")
addprocs(4)
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

@everywhere function myfunc(d::Dict)
    Dict("usage" => "please call me like this",
    "got" => d)
end

facts("call") do
    @spawnat 2 serve(myfunc)
    println("posting ...")
    d = Dict("id" => "123", "data" => zeros(2,3))
    a = jsoncall(d)
    @fact a --> Dict{Any,Any}("usage"=>"please call me like this","got"=>Dict{Any,Any}("id"=>"123","data"=>[0.0 0.0 0.0; 0.0 0.0 0.0]))
end

facts("hdf5") do
    d = Dict("a" => 1)
    filename = tempname()*".hdf5"
    @fact savehdf5(filename,d) --> filename
    @fact loadhdf5(filename) --> d
end

facts("hdf5call") do
    filename1 = tempname()*".hdf5"
    filename2 = tempname()*".hdf5"
    filename3 = tempname()*".hdf5"
    d1 = Dict("data" => savehdf5(filename1, 1))
    d2 = Dict("data" => savehdf5(filename2, Dict("a" => 1)))
    d3 = Dict("data" => Dict("b" => savehdf5(filename3, Dict("a" => 1))))
    encdec(a) = JsonCall.parsejson(JsonCall.makejson(a))
    f1(a) = Dict("result" => a["data"]*2)
    f2(d) = Dict("result" => d["data"]["a"]*2)
    f3(d) = Dict("result" => d["data"]["b"]["a"]*2)
    @fact encdec(d1) --> Dict("data" => 1)
    @fact encdec(d2) --> Dict("data" => Dict("a" => 1))
    @fact encdec(d3) --> Dict("data" => Dict("b" => Dict("a" => 1)))
    @spawnat 3 serve(f1, 8001)
    @spawnat 4 serve(f2, 8002)
    @spawnat 5 serve(f3, 8003)
    sleep(5)
    @fact jsoncall(d1, 8001) --> Dict("result" => 2)
    @fact jsoncall(d2, 8002) --> Dict("result" => 2)
    @fact jsoncall(d3, 8003) --> Dict("result" => 2)
end

