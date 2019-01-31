# Application Store

Objective: Enable applications to have a storage that can be accessed globally.

When using microservices there are information (like tokens and/or secrets) that need to be stored and accessed globally.
Application Store provides a structure in order to enable this functionally.


Use:
```ruby
ApplicationStore.applications(name: 'global-storage')
```
to create a global store. See section Usage for more.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'application_store'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install application_store

## Usage

```ruby
applications = ApplicationStore.applications
  => {:__default__store__ => {}}

some_client  = applications.create name: :some_client
  => #<ApplicationStore::Store:0x00007faf098b4678 @store=#<ApplicationStore::HashStore:0x00007faf098b4628 @store={:name=>:some_client}>>

some_client.set :github_api_token, 'pretty token'
  => "pretty_token"

github_token = some_client.get :github_api_token
  => "pretty_token"

some_client.to_hash
  => {:name => :some_client, :github_api_token => "pretty token"}

applications.to_hash
=> {
        :__default__store__ => {
            :some_client => {
                :name => :some_client,
                :github_api_token => "pretty token"
            }
        }
    }

# rename application
applications.rename 'boo'
  => {:boo => {...}}

# get a particular store
applications.get(:some_client) == some_client
  => true

# delete a store
applications.unset :some_client
  => {:boo => { }}

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/frankapimenta/application_store. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ApplicationStore project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/frankapimenta/application_store/blob/master/CODE_OF_CONDUCT.md).
