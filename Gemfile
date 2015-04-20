source 'https://rubygems.org'

gem "berkshelf", "=2.0.18"
gem 'chef-rewind'
gem 'chef-sugar'

group :test do
  gem 'chef', '~> 11.8'
  gem 'rspec'
  gem 'chefspec'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rake'
end

group :integration do
  gem 'test-kitchen', '~> 1.1.1'
  gem 'kitchen-vagrant'
  gem 'serverspec'
  gem 'busser'
end
