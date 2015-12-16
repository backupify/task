source 'https://rubygems.org'

# Specify your gem's dependencies in task.gemspec
gemspec

gem 'cassava_rb', :git => 'git@github.com:backupify/cassava.git'
gem 'pyper_rb', :git => 'git@github.com:backupify/pyper.git'
gem 'values', :git => 'git@github.com:backupify/values.git'

group :development, :test do
  gem "pry"
  gem "awesome_print"
  gem 'm', :git => 'git@github.com:ANorwell/m.git', :branch => 'minitest_5'
end

group :test do
  gem 'minitest_should', :git => 'git@github.com:citrus/minitest_should.git'
  gem "mocha"
end
