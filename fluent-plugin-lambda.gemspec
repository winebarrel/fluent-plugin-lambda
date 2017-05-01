# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = 'fluent-plugin-lambda'
  spec.version       = '0.2.1'
  spec.authors       = ['Genki Sugawara']
  spec.email         = ['sugawara@cookpad.com']
  spec.description   = %q{Output plugin for AWS Lambda.}
  spec.summary       = %q{Output plugin for AWS Lambda.}
  spec.homepage      = 'https://github.com/winebarrel/fluent-plugin-lambda'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'fluentd'
  spec.add_dependency 'aws-sdk-core', '~> 2.1'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'test-unit', '>= 3.2.0'
end
