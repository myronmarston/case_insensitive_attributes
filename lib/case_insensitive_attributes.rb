require 'active_record'
require 'case_insensitive_attributes/active_record_finders'
ActiveRecord::Base.send :extend, CaseInsensitiveAttributes::ActiveRecordFinders