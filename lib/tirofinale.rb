require 'optparse'
require 'yaml'
require 'logger'
require 'open-uri'

require 'tirofinale/version'

module Tirofinale
  def init_logger
    $logger = Logger.new(STDERR)
    $logger.level = 4
    if level = ENV['LOG_LEVEL']
      $logger.level = level.to_i
    end
  end

  def detect_version_alpine
    content = open('/etc/alpine-release'){|f| f.read }
    major_minor = content.match(/\A(\d\.\d)/)
    major_minor ? major_minor[1] : nil
  end

  def search_apkbuild(gem_name, alpine_version, debug_local_aports = nil)
    dir_list = ['community', 'main', 'non-free', 'testing', 'unmaintained']
    dir_list.each{|dir_name|
      apkbuild_url = "http://git.alpinelinux.org/cgit/aports/plain/#{dir_name}/ruby-#{gem_name}/APKBUILD?h=#{alpine_version + '-stable'}"
      if debug_local_aports
        apkbuild_url = "#{debug_local_aports}/#{dir_name}/ruby-#{gem_name}/APKBUILD"
      end

      begin
        return open(apkbuild_url){|f| f.read}
      rescue OpenURI::HTTPError => e
        next
      rescue Errno::ENOENT => e
        next
      end
    }
    false
  end

  def extract_makedepends(apkbuild)
    variables = []

    # extract quoted variable
    apkbuild.scan(/^([a-z_]+)="(.*?)"/m){|m|
      variables << ({:name => m[0], :value => m[1].gsub(/\s+/, ' ')})
    }

    # extract not quoted variable
    apkbuild.scan(/^([a-z_]+)=([^"]*?)$/){|m|
      variables << ({:name => m[0], :value => m[1].gsub(/\s+/, ' ')})
    }

    variables.sort_by!{|var| var[:name].length * -1}

    variables.each{|var|
      while var[:value].include?('$')
        result = nil
        variables.each{|var2|
          result = result || var[:value].gsub!("$#{var2[:name]}", var2[:value])
        }
        break unless result
      end
    }

    makedepends = variables.select{|var| var[:name] == 'makedepends'}.first
    makedepends ? makedepends[:value] : ''
  end

  def fetch_dep_gems(gem_name, checked = [], level = 0)
    $logger.debug("fetch_dep_gems(). Args:[#{[gem_name, checked, level].join(', ')}]")

    if level > 10
      return []
    end

    dep_gems = []

    url = "https://rubygems.org/api/v1/gems/#{gem_name}.yaml"
    runtime_dep = open(url){|f|
      YAML.load(f.read)['dependencies']['runtime'].map{|dep| dep['name']}
    }

    dep_gems.push(*runtime_dep)
    checked << gem_name

    runtime_dep.each{|dep|
      unless checked.include?(dep)
        dep_gems.push(*fetch_dep_gems(dep, checked, level + 1))
      end
    }

    dep_gems.uniq 

    $logger.info("Gem '#{gem_name}' depends on [#{dep_gems.join(', ')}].")

    dep_gems
  end

  def fetch_build_dep_packages_alpine(gem_name, alpine_version, debug_local_aports)
    $logger.info("Fetch Alpine Linux #{alpine_version} dependency packages to build '#{gem_name}'.")
    apkbuild = search_apkbuild(gem_name, alpine_version, debug_local_aports)
    unless apkbuild
      $logger.warn("Alpine Linux does not have binary package for '#{gem_name}'.")
      return []
    end
    makedepends = extract_makedepends(apkbuild)
    packages = makedepends.strip.split(' ')
    $logger.info("Alpine Linux build dependency packages [#{packages.join(', ')}] for '#{gem_name}'.")
    packages
  rescue => e
    $logger.error(e.inspect)
    $logger.error(e.backtrace)
    raise e
  end

  def run
    init_logger()

    opts = {}

    op = OptionParser.new
    op.on('--dependency'){|val| opts[:dependency] = true}
    op.on('--dist-version VERSION'){|val| opts[:alpine_version] = val}
    op.on('--gem GEM_NAME'){|val| opts[:gem_name] = val}
    op.on('--pretty-print'){|val| opts[:pretty_print] = true}
    op.on('--debug-local-aports PATH'){|val| opts[:debug_local_aports] = val}
    op.parse(ARGV)

    $logger.info "Tirofinale start with #{opts}."

    alpine_version = opts[:alpine_version]
    gem_name = opts[:gem_name]
    dependency = opts[:dependency]
    debug_local_aports = opts[:debug_local_aports]
    pretty_print = opts[:pretty_print]

    unless gem_name
      raise "Missing '--gem GEM_NAME' option."
    end

    unless alpine_version
      $logger.info('Attempt to auto detect Alpine Linux version.')
      alpine_version = detect_version_alpine()
      $logger.info("Alpine Linux version '#{alpine_version}' was detected.")
    end

    packages = fetch_build_dep_packages_alpine(gem_name, alpine_version, debug_local_aports)

    if dependency
      dep_gem_list = fetch_dep_gems(gem_name)

      dep_gem_list.each{|dep_gem_name|
        dep_packages = fetch_build_dep_packages_alpine(dep_gem_name, alpine_version, debug_local_aports)
        packages.push(*dep_packages) unless dep_packages.empty?
      }

      packages.uniq!
    end

    $logger.info("This environment require packages [#{packages.join(', ')}] to install gem '#{gem_name}'.")

    if pretty_print
      puts "This environment require following packages to install gem '#{gem_name}'."
      packages.each{|package|
        puts "    #{package}"
      }
    else
      print packages.join(' ')
    end

    $logger.info "Tirofinale done."
  end
end
