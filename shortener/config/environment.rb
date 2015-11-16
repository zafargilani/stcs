# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

p Shortener::ShortenedUrl.generate("https://t.co/OhIcm3l4fA")