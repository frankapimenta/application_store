# Application Store

Objective: Enable applications to have a key-value (dictionary) storage that can be accessed globally across the app's code.
Sometimes doing:
```ruby
Rails.application.config_for(:<key>)
```
all the time is not enough!

When using microservices there are many pieces of information (like tokens and/or secrets) that need to be stored and accessed globally by the different microservices.
Application Store provides a data structure in order to enable this functionally across the microservices


Use:

```ruby
ApplicationStore.store
```
to create a global store. See section **Usage** for more.

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
store = ApplicationStore.store
  => {:__default__store__ => {}}

some_client  = store.create name: :some_client
  => #<ApplicationStore::Store:0x00007ff3758e4f98 @store=#<ApplicationStore::HashStore:0x00007ff3758e4f48 @store={:name=>:some_client}, @parent=nil>, @parent=#<ApplicationStore::HashStore:0x00007ff374b3ded0 @store={:some_client=>#<ApplicationStore::Store:0x00007ff3758e4f98 ...>}, @parent=nil>>

some_client.set :github_api_token, 'pretty token'
  => "pretty_token"

github_token = some_client.get :github_api_token
  => "pretty_token"

# Instead of calling ```#get :<key>``` you could also directly send the message to the receiver:
some_client.github_api_token
  => "pretty_token"

some_client.to_hash
  => {:name => :some_client, :github_api_token => "pretty token"}

store.to_hash
=> {
        :__default__store__ => {
            :some_client => {
                :name => :some_client,
                :github_api_token => "pretty token"
            }
        }
    }

# rename global store
store.rename 'boo'
  => {:boo => {...}}

store.to_hash
  {
      :boo => {
          :some_client => {
                          :name => :some_client,
              :github_api_token => "pretty token"
          }
      }
  }

# get a particular store stored in store
store.get(:some_client) == some_client
  => true
# or
store.some_client == some_client
  => true

# delete a store
store.unset :some_client
  => {:boo => { }}

```
Many times one needs/has to access a lot of values. Best is to use a yaml configuration file to get values from (operating system) environment variables.
You can create a YAML file with this values.
**note**: The default name for the file is 'application_store.yml'. The outermost yaml key in the file must have the same name as the file's name.

```ruby
=> config/application_store.yml
```

#### example
The yaml file:
```yml
application_store:
  development:
    finance_manager:
      configurations:
        email:
          smtp:
            host: 'development.smtp.x.ch'
          pop3:
            host: 'development.pop3.x.ch'
      contacts_client:
        host: 'development.localhost'
        port: 3001
        api_key: 'development.asdasdasdasd'
  staging:
    finance_manager:
      configurations:
        email:
          smtp:
            host: 'staging.smtp.x.ch'
          pop3:
            host: 'staging.pop3.x.ch'
      contacts_client:
        host: 'staging.localhost'
        port: 3002
        api_key: 'staging.asdasdasdasd'
````
The code to run

```ruby
# You can pass the configuration file name (when different than the default name) via keyword argument :filename
#   AplicationStore.run! environment: :development, file_name: 'another_application_store.yml'
# The outermost key of this yaml file must be :another_application_store
ApplicationStore.run!(environment: :development)
=> {
        "finance_manager" => {
             "configurations" => {
                "email" => {
                    "smtp" => {
                        "host" => "development.smtp.x.ch"
                    },
                    "pop3" => {
                        "host" => "development.pop3.x.ch"
                    }
                }
            },
            "contacts_client" => {
                   "host" => "development.localhost",
                   "port" => 3001,
                "api_key" => "development.asdasdasdasd"
            }
        }
    }

ApplicationStore.store.finance_manager.configurations.email.smtp.host
  => "development.smtp.x.ch"
```

**note**: The environment to consider is passed directly in ::run. However you can set the environment via ENV var:

````
APPLICATION_STORE_ENVIRONMENT=<environment> bin/console
````

This will be the environment the gem is running in when calling ::run without passing the env directly via keword argument.

When in a Rails app, if this the ENV var is not defined, and no environment is set directly via keyword argument, then the Rails.env is considered.

#### ApplicationStore::rails_app

You can use ::rails_app when working within a rails application.

```ruby
  ApplicationStore::rails_app
    => ApplicationStore::RailsApplication:0x00007fe9f29011c
```

You can then send messages to this instance and they will be forward to either #config (if config responds to the message) or #config_for (if config does not responds to the message) of rails application.

### Console

When runnning the gem in an app or the console you need to set either the root path or the full path to 'application_store.yml' (configuration file).

```
APPLICATION_STORE_ROOT_PATH=~/development bin/console
```
the gem will look for the application_store.yml in ~/development/config

or:
```
APPLICATION_STORE_CONFIG_PATH=~/development/config
```
to provide the path where the configuration file already is.

The gem will use Rails.root as APPLICATION_STORE_ROOT_PATH and 'config' folder as APPLICATION_STORE_CONFIG_PATH when in a rails app context:

```ruby
    ApplicationStore.run! #environment and path to config file (application_store.yml) comes from ENV vars
```

When in an rails app create a initializer and call the same line above.

To set both the path to configuration file and the environment to run in, do:

```
APPLICATION_STORE_ROOT_PATH=~/development APPLICATION_STORE_ENVIRONMENT=development bin/console
```
or
```
APPLICATION_STORE_CONFIG_PATH=~/development/config APPLICATION_STORE_ENVIRONMENT=development bin/console
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
