# Tirofinale

'Tiro finale!' to build ruby native extension.

This is experimental gem and not work fine yet for any enviroment and gem.

## Installation

~~~~
# gem install tirofinale
~~~~

## Usage

On Alpine Linux v3.4 only.

Show packages which is required to build `nokogiri` gem.

~~~~
$ tirofinale nokogiri
ruby-dev libxml2-dev libxslt-dev
~~~~
You can install packages by `apk` following line.

~~~~
# apk add `tirofinale nokogiri`
~~~~

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

