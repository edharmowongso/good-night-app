# Configure shoulda-matchers
require 'shoulda/matchers'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Custom shoulda matcher for conditional validations
RSpec::Matchers.define :validate_presence_of_conditionally do |attribute|
  match do |model|
    model.send("#{attribute}=", nil)
    model.valid?
    model.errors[attribute].any?
  end
  
  chain :conditional do
    # This just marks the matcher as conditional
  end
  
  description do
    "validate presence of #{attribute} conditionally"
  end
  
  failure_message do |model|
    "expected #{model.class} to validate presence of #{attribute} conditionally"
  end
end
