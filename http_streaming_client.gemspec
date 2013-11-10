# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'http_streaming_client/version'

Gem::Specification.new do |spec|
  spec.name          = "http_streaming_client"
  spec.version       = HttpStreamingClient::VERSION
  spec.authors       = ["David Tompkins"]
  spec.email         = ["tompkins@adobe.com"]
  spec.description   = %q{Ruby HTTP client with streaming support for GZIP compressed streams and chunked transfer encoding. Also includes extensible OAuth support for Adobe and Twitter streaming APIs.}
  spec.summary       = %q{a streaming HTTP protocol client}
  spec.homepage      = "https://git.corp.adobe.com/tompkins/http_streaming_client"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"

  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "typhoeus"
  spec.add_runtime_dependency "nokogiri"
end
