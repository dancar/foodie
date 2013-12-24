require_relative 'givebyte'

namespace :givebyte do

  desc "Reset 10Bis rests"
  task :reset do
    GiveByte.reset_rests
  end

  task :update_rests do
    GiveByte.update_rests
  end

  task :get_rests do
    require 'pp'
    pp GiveByte.get_rests
  end

end
