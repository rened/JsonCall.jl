M ubuntu:14.04

RUN apt-get update
RUN apt-get install -y curl git cmake
RUN apt-get install -y libc6-dev gcc build-essential

RUN mkdir -p ~/julia
RUN curl -s -L https://julialang.s3.amazonaws.com/bin/linux/x64/0.4/julia-0.4.3-linux-x86_64.tar.gz | \
  tar -C ~/julia -x -z --strip-components=1 -f -
RUN echo "export PATH=$PATH:$HOME/julia/bin" >> ~/.profile

RUN ~/julia/bin/julia -e "Pkg.clone(\"http://github.com/rened/JsonCall.jl\")"

