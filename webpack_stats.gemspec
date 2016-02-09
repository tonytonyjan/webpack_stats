$:.unshift File.expand_path('../lib', __FILE__)
require 'webpack_stats/version'

Gem::Specification.new do |spec|
  spec.name        = 'webpack_stats'
  spec.version     = WebpackStats::VERSION
  spec.authors     = 'Jian Weihang'
  spec.email       = 'tonytonyjan@gmail.com'
  spec.licenses    = ['MIT']
  spec.summary     = 'Webpack Stats loader for Rails'
  spec.description = 'Webpack Stats loader for Rails'
  spec.homepage    = 'https://github.com/tonytonyjan/webpack_stats'
  spec.files       = ['lib/webpack_stats.rb']
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.5'
  spec.add_development_dependency 'rake-compiler', '~> 0.9'
  spec.add_development_dependency 'minitest', '~> 5.8'
end