ENV["RAILS_MASTER_KEY"] = "5b762eb3faa07acd0fa3e61e8ca33e33"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
