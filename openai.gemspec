require_relative "lib/openai/version"

Gem::Specification.new do |spec|
  spec.name          = "openai"
  spec.version       = OpenAI::VERSION
  spec.authors       = ["Nilesh Trivedi", "Erik Berlin"]
  spec.email         = ["git@nileshtrivedi.com", "sferik@gmail.com"]

  spec.summary       = "OpenAI API client library to access GPT-3 in Ruby"
  spec.description   = "OpenAI API client library to access GPT-3 in Ruby"
  spec.homepage      = "https://github.com/nileshtrivedi/openai"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nileshtrivedi/openai"
  spec.metadata["changelog_uri"] = "https://github.com/nileshtrivedi/openai/blob/master/changelog.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2"
  spec.add_development_dependency "rake", ">= 10"
  spec.add_development_dependency "rspec", ">= 3.9"
  spec.add_development_dependency "webmock", ">= 3.8"
end
