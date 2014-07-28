require 'cezanne'
require 'rspec/core'

RSpec.configure do |config|

  config.add_setting :cezanne

  config.before(:all) do
    if self.class.include?(Cezanne)
      uid = config.cezanne[:uid]
      project_name = config.cezanne[:project_name]
      config.cezanne[:local_files] = Cezanne::LocalFiles.new(uid, 'artifacts')
      config.cezanne[:remote_files] = Cezanne::RemoteFiles.new(uid, project_name)
      begin
        config.cezanne[:remote_files].pull(:ref, config.cezanne[:local_files].path_for(:ref))
      rescue 
        puts "no reference screenshot exist for project #{project_name}"
      end
    end
  end

  config.after(:all) do
    if self.class.include?(Cezanne)
      [:new, :diff].each do |key|
        config.cezanne[:remote_files].push(cezanne.config[:local_files].path_for(key), key)
      end
      cezanne.config[:local_files].clean
    end
  end

end

module Cezanne

  def local_files
    RSpec.configuration.cezanne[:local_files]
  end

  def remote_files
    RSpec.configuration.cezanne[:remote_files]
  end

end
