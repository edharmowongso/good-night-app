class ApplicationRecord < ActiveRecord::Base
  include TimeHelper
  
  primary_abstract_class
end
