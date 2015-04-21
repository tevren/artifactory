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
  gem 'test-kitchen'
  gem 'kitchen-vagrant'
  gem 'busser-serverspec'
  gem 'serverspec'
end
