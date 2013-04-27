source "https://rubygems.org"
gemspec

gem 'activesupport', '~> 3.2.0'
gem 'activemodel',   '~> 3.2.0'
gem 'rake',          '~> 0.9.0'
gem 'oj',            '~> 1.0.0'
gem 'multi_json',    '~> 1.3.2'
gem 'metriks', :require => false
gem 'statsd-ruby', :require => false

group(:guard) do
  gem 'guard',          '~> 1.0.0'
  gem 'guard-rspec',    '~> 0.6.0'
  gem 'guard-bundler',  '~> 0.1.0'
end

group(:test) do
  gem 'rspec',      '~> 2.8.0'
  gem 'timecop',    '~> 0.3.0'
  gem 'tzinfo',     '~> 0.3.0'
  gem 'rack-test',  '~> 0.6.0'
end
