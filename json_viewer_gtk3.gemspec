# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jsonview/version'

Gem::Specification.new do |spec|
  spec.name          = 'json_viewer_gtk3'
  spec.version       = JsonView::VERSION
  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.summary       = 'Simple GUI Json viewer'
  spec.description   = 'Simple GUI Json Viewer'
  spec.homepage      = 'https://github.com/kojix2/json_viewer_gtk3'
  spec.license       = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'gtk3'
  spec.add_dependency 'webkit2-gtk'
  spec.add_dependency 'yard'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
