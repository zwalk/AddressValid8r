# Address::Valid8r

Wrapper gem to read a csv of addresses and validate them with Smarty

valid8 u l8r, sk8r... sorry, i'll go.

## Installation

As of writing these instructions, I used:
- gem -v `3.3.26`
- ruby -v `3.1.4p223`
- bundler -v `2.3.26`

1. Pull this repo to your machine

2. cd into the AddressValid8r directory

3. run `gem build address-valid8r.gemspec`

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

4. run `gem install ./address-valid8r-0.1.0.gem`

    output:
    
    ```
    Successfully installed address-valid8r-0.1.0
    Parsing documentation for address-valid8r-0.1.0
    Done installing documentation for address-valid8r after 0 seconds
    1 gem installed
    ```
   
the command `address-valid8r` should now be available in your terminal

#### alternative

If there is issues with the installation, this can be run directly via:

1. make sure your terminal is at the location of the root dir of this code base
2. `./exe/address-valid8r -f /your/file/path`

## Setting API Key, Token, and License

Upon first run, address-valid8r will ask you for these values.
```shell
Enter your Auth id:
Enter your Auth token:
Enter your License type:
```
The values that are input are hidden. They will be added to your local .env file within the root directory of this code base. 

The values can be reset by adding the `-r` or `--reset` flag, which will prompt the script to ask you for these values again

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

## Running Tests
From the root directory of this code base, run:
`bundle exec rspec`

## Running Rubocop
From the root directory of this code base, run:
`bundle exec rubocop`
