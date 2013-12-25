require_relative 'givebyte'
require 'pp'

namespace :givebyte do

  desc "Reset 10Bis rests"
  task :reset do
    GiveByte.reset_rests
  end

  desc "Update rests cache"
  task :update_rests do
    GiveByte.update_rests
  end

  desc "Display rests cache"
  task :get_rests do
    pp GiveByte.get_rests
  end

end
