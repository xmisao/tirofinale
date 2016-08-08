# Tirofinale

'Tiro finale!' to build ruby native extension.

This is experimental gem and not work fine yet for any enviroment and gem.

## Installation

~~~~
# gem install tirofinale
~~~~

## Requirements

Alpine Linux from v2.6 to v3.4 only.

## Usage

~~~~
$ tirofinale --help
Usage: tirofinale [options]
        --dependency
        --dist-version VERSION
        --gem GEM_NAME
        --pretty-print
        --debug-local-aports PATH
~~~~

Default output format is optimized to shell.
You can install required packages to install `nokogiri` gem by `apk` command following line.

~~~~
# apk add `tirofinale --gem nokogiri`
~~~~

Human readable output gettable by `--pretty-print` option.

~~~~
$ tirofinale --gem nokogiri --pretty-print
This environment require following packages to install gem 'nokogiri'.
    ruby-dev
    libxml2-dev
    libxslt-dev
~~~~

Distribution version is detected automatically when you run `tirofinale` on Alpine Linux environment.
If you specify version manually, you can use `--dist-version VERSION` option.
The following line show packages which are required to build `nokogiri` gem on Alpine Linux v3.4 on any environment.

~~~~
$ tirofinale --dist-version 3.4 --gem nokogiri
~~~~

Dependency of gem to gems will be resolved by Tirofinale's `--dependency` option.
For example, `thin` gem depends on `daemons` gem, `eventmachine` gem and `rack` gem.
And, `openssl-dev` package is required to build `eventmachine` on Alpine Linux.
In folowing example, Tirofinale show distribution packages dependent by `thin` gem and `thin` gem depdns on gems.

~~~~
$ tirofinale --gem thin --dependency --pretty-print
This environment require following packages to install gem 'thin'.
    ruby-dev
    openssl-dev
    ruby
~~~~

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

