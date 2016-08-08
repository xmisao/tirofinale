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

Default output format is optimized for shell.
You can install required packages to install `nokogiri` gem following lines.

~~~~
# apk add `tirofinale --gem nokogiri`
# gem install nokogiri # successful!
~~~~

Human friendry output format gettable by specifying `--pretty-print` option.

~~~~
$ tirofinale --gem nokogiri --pretty-print
This environment require following packages to install gem 'nokogiri'.
    ruby-dev
    libxml2-dev
    libxslt-dev
~~~~

Tirofinale read `/etc/alpine-release` file and detect Alpine Linux version automatically.
If you want to specify version manually, you can use `--dist-version VERSION` option.

~~~~
$ tirofinale --dist-version 3.4 --gem nokogiri
~~~~

Tirofinale resolve dependency of a gem to gems when specify `--dependency` option.

For example, `thin` gem depends on `daemons` gem, `eventmachine` gem and `rack` gem.
`openssl-dev` package is required to install `eventmachine` gem on Alpine Linux.

Folowing example, Tirofinale show distribution packages required by installing `thin` gem and `thin` gem depends to gems.

~~~~
$ tirofinale --gem thin --dependency --pretty-print
This environment require following packages to install gem 'thin'.
    ruby-dev
    openssl-dev
    ruby
~~~~

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

