# VirtualGem

Create virtual gem version for checking dependency.


# The purpose

This dependency setting include alpha and beta version.
So this setting include "0.1.0", "0.2.1", "0.3.0.rc1"
```
spec.add_dependency "ota42y_test_gem", "< 0.3"
```

And when "0.3.0" released, we can't install it because "< 0.3" does't include "0.3.0".

We already test release candidate version so "0.3.0" will work well.
But we can't check until "0.3.0" released.

For example, when `ota42y_dependent_test_gem` depends `ota42y_test_gem` '< 0.3', this setting well success.
```ruby
gem 'ota42y_dependent_test_gem', '0.2.0'
gem 'ota42y_test_gem', '0.2.0'
```

And this setting will fail because we can't resolve dependency.
```ruby
gem 'ota42y_dependent_test_gem', '0.2.0' # require 'ota42y_test_gem', '< 0.3'
gem 'ota42y_test_gem', '0.3.0'
```

But 'ota42y_test_gem' version '0.3.0' isn't released!
So rubygems exit on finding gem process and we can't check dependency.

```
$ bundle update ota42y_test_gem
Fetching gem metadata from https://rubygems.org/.........
Could not find gem 'ota42y_test_gem (= 0.3.0)' in any of the gem sources listed in your Gemfile.
```

`virtual_gem` create new version gem from old version.
When use `virtual_gem`, we can pass finding process and check dependency.

```
$ bundle update ota42y_test_gem
Fetching gem metadata from https://rubygems.org/.........
Resolving dependencies...
Bundler could not find compatible versions for gem "ota42y_test_gem":
  In Gemfile:
    ota42y_test_gem (= 0.3.0)

    ota42y_dependent_test_gem (= 0.2.0) was resolved to 0.2.0, which depends on
      ota42y_test_gem (< 0.3)
```

Even if we create virtual_gem, bundle will fail by dependencies error.
So this gem provide overwrite gem dependencies
We can change `ota42y_dependent_test_gem` depends `ota42y_test_gem` '< 0.3' to '<= 0.3', so we can pass and check next dependencies.

## Installation

    $ gem install virtual_gem

## Usage
Please write this line to your Gemfile

```ruby
::VirtualGem.register_virtual_gem(name: 'ota42y_test_gem',new_version: '0.3.0', original_version: '0.2.0')

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

require 'bundler'

gem 'ota42y_test_gem', '0.3.0'
```

This code create 'ota42y_test_gem' version 0.3.0 using 0.2.0 gem.
We don't release '0.3.0' yet but bundle install will success.

```
% bundle install
Using bundler 1.16.1
Using ota42y_test_gem 0.3.0
```

If you want to override gem requirement, use register_requirements_changes.

```
::VirtualGem.register_requirements_changes(name: 'ota42y_dependent_test_gem', version: '0.2.0', new_requirements: { 'ota42y_test_gem': ['<= 0.3'] })
```

'ota42y_dependent_test_gem' version '0.2.0' depends on 'ota42y_test_gem' version '< 0.3' but this method change depends on '<=0.3'.

## Important notice
We check `bundle install` process only.
So don't use `virtual_gem` for execute ruby script.
(We don't change ::GEM_NAME::VERSION so many gem will doesn't work well.)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/virtual_gem. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the VirtualGem project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/virtual_gem/blob/master/CODE_OF_CONDUCT.md).
