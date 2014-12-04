require 'cezanne'
require 'rspec/core'

RSpec.configure do |config|

  config.before(:all, screenshots: true) do
    if self.class.include?(Cezanne)
      begin
        Cezanne.config.remote_files.pull(:ref, Cezanne.config.local_files.path_for(:ref))
      rescue 
        puts "no reference screenshot exist for project #{Cezanne.config.project_name}"
      end
    end
  end

  config.after(:all, screenshots: true) do
    if self.class.include?(Cezanne)
      [:new, :diff].each do |key|
        Cezanne.config.remote_files.push(Cezanne.config.local_files.path_for(key), key)
      end
      Cezanne.config.local_files.clean
    end
  end

end
