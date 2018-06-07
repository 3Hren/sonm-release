#!/usr/bin/env ruby

# rsync -avz release/ builder:~/release

version = '0.4.0-alpha2'

dists = ['ubuntu:16.04']

artifacts = [
    "sonm-dwh_#{version}_amd64.deb",
    "sonm-optimus_#{version}_amd64.deb",
    "sonm-rendezvous_#{version}_amd64.deb",
    "sonm-cli_#{version}_amd64.deb",
    "sonm-node_#{version}_amd64.deb",
    "sonm-relay_#{version}_amd64.deb",
    "sonm-worker_#{version}_amd64.deb",
    "sonm-core_#{version}_amd64.build",
    "sonm-core_#{version}_amd64.changes",
]

def run_cmd(&block)
  output = yield block
  raise "[#{$?.exitstatus}]: #{output}" unless $?.exitstatus == 0
  output
end

dists.each do |dist|
    puts "-> #{dist}"

    dockerfile = File.read('Dockerfile.template') % {'dist': dist}
    File.write('Dockerfile', dockerfile)

    puts "-> docker build #{dist}"
    output = run_cmd do
      %x[docker build .]
    end

    container_id = output.split(/\n/, -1)[-2].split(' ', -1)[2]

    puts "-> docker cp #{dist}"

    dist = dist.gsub!(':','_')
    out = "v#{version}-#{dist}"
    %x[mkdir #{out}]

    %x[docker run -it -v ${PWD}/#{out}:/go/src/github.com/sonm-io/release #{container_id} cp -R /go/src/github.com/sonm-io/core/target /go/src/github.com/sonm-io/release/]

    artifacts.each do |v|
      %x[docker run -it -v ${PWD}/#{out}:/go/src/github.com/sonm-io/release #{container_id} cp /go/src/github.com/sonm-io/#{v} /go/src/github.com/sonm-io/release/]
    end
end

# rsync -avz builder:~/release/ ~/release/
