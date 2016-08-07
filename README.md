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
Usage: tirofinale [options]
        --dist-version VERSION
        --gem GEM_NAME
~~~~

Show packages which is required to build `nokogiri` gem on Alpine Linux v3.4.

~~~~
$ tirofinale --dist-version 3.4 --gem nokogiri
ruby-dev libxml2-dev libxslt-dev
~~~~

Auto detect Alpine Linux version by run without `--dist-version` parameter.

~~~~
$ tirofinale --gem nokogiri
ruby-dev libxml2-dev libxslt-dev
~~~~

You can install packages by `apk` following command.

~~~~
# apk add `tirofinale --gem nokogiri`
~~~~

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

