# JsonCall

[![Build Status](https://travis-ci.org/rened/JsonCall.jl.svg?branch=master)](https://travis-ci.org/rened/JsonCall.jl)

Allows to expose a Julia function over a simple JSON interface:

```jl
using JsonCall
f(d::Dict) = Dict("result" => d["data"]*2)
serve(f)
```

The naming of the fields is up to you. The representation of multi-dimensional arrays in the JSON string is as follows (which you only have to worry about if you want to write your own wrapper in another language):

```jl
println(JsonCall.makejson([1 2 3;4 5 6]))
# will print:
{"arraydata":[1,4,2,5,3,6],"arraysize":[2,3]}
```

## Passing HDF5 files

In case your data is too large or does not fit into the aforementioned array serialization, you can pass data as HDF5 files instead. This can be done for either the data, the result, or both. You can pass a existing HDF5 filename (always ending in `.hdf5`), or use the convenience function `savehdf5(d::Dict)`:

```jl
using JsonCall

filenameIN = tempname()*".hdf5"
filenameOUT = tempname()*".hdf5"

x = ones(Float32, 2, 3)
d = Dict("data" => savehdf5(filename, x))

f(a) = Dict("result" => savehdf5(tempname(), a["data"]*2))
serve(f)

jsoncall(d) == Dict("result" => 2*x)    # true
```
