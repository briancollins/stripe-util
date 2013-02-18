require File.expand_path('../lib/stripe-util/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Brian Collins"]
  gem.email         = ["brian@stripe.com"]
  gem.description   = %q{Some Stripe-related utilities}
  gem.summary       = ""
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "stripe-util"
  gem.require_paths = ["lib"]
  gem.version       = Stripe::Util::VERSION

  gem.add_dependency 'stripe'
end