load '../../exe/tirofinale'
require 'pp'

path_to_aports = ARGV[0]

init_logger()

all_deps = []

ruby_packages = open('../../data/ruby-packages'){|f| f.read}
ruby_packages.each_line{|l|
  begin
    name = l.match(/ruby-(.+)$/)[1]
    deps = fetch_build_dep_packages_alpine(name, '3.4', path_to_aports)

    all_deps << {:name => name, :deps => deps}
  rescue => e
    puts "Error occured name='#{name}'"
    p e.inspect
    pp e.backtrace
  end
}

all_deps.sort_by!{|dep| dep[:deps].size}

all_deps.each{|dep|
  puts "#{dep[:name]} => [#{dep[:deps].join(', ')}]"
}
