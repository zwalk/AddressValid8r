# Address::Valid8r

Wrapper gem to read a csv of addresses and validate them with Smarty

valid8 u l8r, sk8r... sorry, i'll go.

## Installation

Pull this repo to your machine and then cd into the AddressValid8r directory

run `gem build address-valid8r.gemspec`

output:

```
WARNING:  licenses is empty, but is recommended.  Use a license identifier from
http://spdx.org/licenses or 'Nonstandard' for a nonstandard license.
WARNING:  See https://guides.rubygems.org/specification-reference/ for help
  Successfully built RubyGem
  Name: address-valid8r
  Version: 0.1.0
  File: address-valid8r-0.1.0.gem
```

run `gem install ./address-valid8r-0.1.0.gem`

output:

```
Successfully installed address-valid8r-0.1.0
Parsing documentation for address-valid8r-0.1.0
Done installing documentation for address-valid8r after 0 seconds
1 gem installed
```
the command `address-valid8r` should now be available

## Setting API Key, Token, and License

For the sake of this exercise, we will just store them in the super secret [.env](https://github.com/zwalk/AddressValid8r/blob/main/.env) file, just switch those values to yours

## Usage

Address Valid8r takes one option that can be assigned with the shorthand -f or longer --file followed by the file path to the addresses you want to validate

Example:
```bash
address-valid8r -f /Users/you/documents/addresses/address_list.csv
```
OR
```bash
address-valid8r --file /Users/you/documents/addresses/address_list.csv
```

There is a small help page if this option is forgotten by running
```bash
address-valid8r --help
```

the csv at the file path provided must have a header row.
The accepted headers are `street`, `city`, `state`, `zip code`

Ex:
```csv
Street, City, Zip Code
143 e Maine Street, Columbus, 43215
1 Empora St, Title, 11111
, Dublin, 00000
```

**note** state is left out here and the gem should still be able to send it through for validation. The Street field is the only absolutely required field, 
but if that is all that is sent in, it must include at least a street address and the zip code

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zwalk/address-valid8r.
