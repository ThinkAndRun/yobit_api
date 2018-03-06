
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yobit_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'yobit_api'
  spec.version       = YobitApi::VERSION
  spec.authors       = ['Oleg Belov']

  spec.summary       = %q{Yet another Yobit.net API wrapper}
  spec.description   = %q{Yet another Yobit.net API wrapper}
  spec.homepage      = 'https://github.com/ThinkAndRun/yobit_api'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'openssl'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'addressable'
end
