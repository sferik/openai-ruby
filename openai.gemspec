require_relative "lib/openai/version"

Gem::Specification.new do |spec|
  spec.name = "openai"
  spec.version = OpenAI::VERSION
  spec.authors = ["Erik Berlin", "Nilesh Trivedi"]
  spec.email = ["sferik@gmail.com", "git@nileshtrivedi.com"]

  spec.summary = "A Ruby interface to the OpenAI API."
  spec.homepage = "https://sferik.github.io/openai-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.3"
  spec.platform = Gem::Platform::RUBY

  spec.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "rubygems_mfa_required" => "true",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/sferik/openai-ruby",
    "changelog_uri" => "https://github.com/sferik/openai-ruby/blob/master/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/sferik/openai-ruby/issues",
    "documentation_uri" => "https://rubydoc.info/gems/openai/"
  }

  spec.files = Dir[
    "bin/*",
    "lib/**/*.rb",
    "sig/*.rbs",
    "*.md",
    "LICENSE.txt"
  ]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
