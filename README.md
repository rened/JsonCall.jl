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


