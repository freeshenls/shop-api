ENV["RAILS_MASTER_KEY"] = "ab1c08c090501039ffb78ff3a4f95e78"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
