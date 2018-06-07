#!/usr/bin/env ruby

# This script prepares GitHub release by parsing debian/changelog as like as
# calculating SHA1 for each binary ready to be published.

# Version of this release.
VERSION = 'v0.4.0-alpha2'

# OS.
SYSTEMS = ['linux', 'darwin', 'windows']

# Architectures.
ARCH = {
  'linux' => 'x86_64',
  'darwin' => 'x86_64',
  'windows' => '386',
}

EXE = {
  'linux' => '',
  'darwin' => '',
  'windows' => '.exe'
}

# Components we want to publish.
COMPONENTS = ['worker', 'optimus', 'node', 'cli']

COMPONENTS_MAP = {
  'worker' => 'Worker',
  'optimus' => 'Optimus',
  'node' => 'Node',
  'cli' => 'CLI',
}

PATHS_MAP = {
  'linux' => 'ubuntu-16.04',
  'darwin' => 'darwin',
  'windows' => 'windows',
}

artifacts = {}
COMPONENTS.each do |v|
  SYSTEMS.each do |os|
    path = "~/release/#{VERSION}/#{PATHS_MAP[os]}/target"
    artifacts[v] ||= []
    component = "sonm#{v}_#{os}_#{ARCH[os]}#{EXE[os]}"
    sha = %x[shasum #{path}/#{component}].split(' ')[0]
    artifacts[v] << [component, sha]
  end
end

rows = []
rows << "|Component|Linux|OS X|Windows|"
rows << "|:-:|-|-|-|"

artifacts.each do |k, v|
  c = COMPONENTS_MAP[k]
  row = "|#{c}|"
  v.each do |vv|
    url = "https://github.com/sonm-io/core/releases/download/#{VERSION}/#{vv[0]}"
    sha = vv[1]
    if sha == nil
      sha = ''
      url = nil
    else
      url = "[`SHA1 #{sha}`](#{url})"
    end
    row += "#{url}|"
  end
  rows << row
end

puts rows.join("\n")
