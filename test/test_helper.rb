require 'rubygems'
require 'case_insensitive_attributes'
require 'test/unit'
require 'shoulda'
require 'erb'

begin
  require 'ruby-debug'
  Debugger.start
  Debugger.settings[:autoeval] = true if Debugger.respond_to?(:settings)
rescue LoadError
  # ruby-debug wasn't available so neither can the debugging be
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'lib/database.rb'

config_dir = File.dirname(__FILE__) + '/config/%s'
db_config_file = File.exists?(config_dir % 'database.yml') ? config_dir % 'database.yml' : config_dir % 'default_database.yml'
db_config = YAML::load(ERB.new(IO.read(db_config_file)).result)['test']
Database.drop_database(db_config)
Database.create_database(db_config)

require 'lib/schema'
require 'lib/models'

class Test::Unit::TestCase
end