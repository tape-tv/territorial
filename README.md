# Territorial

If you have to work with lists of ISO 3166-1 alpha-2 country codes that
sometimes include fake codes that should be expanded to a longer list, e.g.
'EU', or if you have to deal with lists of territory metadata like 'EU -FR'
then territorial will help. It defines some commonly seen default expansion
codes, and allows you to correctly expand a string like 'EU -FR' into an
array of 2-letter country codes

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'territorial'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install territorial

## Usage

Basic region expansion is very simple:

```ruby
Territorial.expand(:GSA)
# => ['DE', 'CH', 'AT']

Territorial.expand(['GSA', EFTA'])
# => ['DE', 'CH', 'AT', 'NO', 'LI', 'IS']
```

Available regions:

* `GSA` - Germany, Switzerland, Austria
* `EU` - European Union
* `EFTA` - European Free Trade Association
* `WW` - Worldwide

You can instantiate a Territorial instance directly with your own extra regions
defined, or override the defaults:

```ruby
t = Territorial.new(Anglophone: ['GB', 'US', 'CA', 'AU', 'NZ', 'ZA'])
t.expand(:Anglophone)
# => ['GB', 'US', 'CA', 'AU', 'NZ', 'ZA']
```

You can also parse strings listing territories and regions:

```ruby
t = Territorial.new
t.parse('GSA -DE')
# => ['AT', 'CH']
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release` to create a git tag for the version, push git
commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/territorial/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request





