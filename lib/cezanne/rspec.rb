require 'cezanne'
require 'rspec/core'

RSpec.configure do |config|

  config.before(:all, screenshots: true) do
    if self.class.include?(Cezanne)
       if Cezanne.config.remote_files.exists? :ref   
         Cezanne.config.remote_files.pull(:ref, Cezanne.config.local_files.path_for(:ref))
       else 
         Cezanne.config.remote_files.push(Cezanne.config.local_files.path_for(:ref), :ref)
       end   
    end
  end

  config.after(:all, screenshots: true) do
    if self.class.include?(Cezanne)
      [:new, :diff].each do |key|
        Cezanne.config.remote_files.push(Cezanne.config.local_files.path_for(key), key) unless Dir.glob(Cezanne.config.local_files.path_for(key)).empty?
      end
      Cezanne.config.local_files.clean
    end
  end

end
