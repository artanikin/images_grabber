# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ImagesGrabber::Application.initialize!

require "open-uri"
require "core_extensions/string"