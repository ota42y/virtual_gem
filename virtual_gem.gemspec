
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'virtual_gem/version'

Gem::Specification.new do |spec|
  spec.name          = 'virtual_gem'
  spec.version       = VirtualGem::VERSION
  spec.authors       = ['ota42y']
  spec.email         = ['ota42y@gmail.com']

  spec.summary       = 'create virtual gem and for checking dependency'
  spec.description   = 'create virtual gem and for checking dependency'
  spec.homepage      = 'https://github.com/ota42y/virtual_gem'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'fincop'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
