require_relative 'givebyte'
require 'pp'

desc 'Reset 10Bis rests'
task :reset do
  GiveByte.reset_rests
end

desc 'Update rests cache'
task :update do
  GiveByte.update_rests
end

desc 'Display rests cache'
task :print do
  pp GiveByte.get_rests
end
