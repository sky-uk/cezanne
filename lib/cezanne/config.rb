module Cezanne

  Config = Struct.new(:uid, :project_name, :local_root, :remote_root, :local_files, :remote_files, :comparison_method)  
 
  def self.config
    @config ||= Cezanne::Config.new
  end


  def self.configure 
    config = Cezanne.config 

    yield config if block_given?

    config.comparison_method ||= :phash_hamming_distance 
    config.local_root ||= 'artifacts'
    config.remote_root ||= config.project_name
    config.local_files ||= Cezanne::LocalFiles.new(config.uid, config.local_root) 
    config.remote_files ||= Cezanne::RemoteFiles.new(config.uid, config.remote_root) 
  end

  private

    def local_files 
      Cezanne.config.local_files
    end

    def remote_files 
      Cezanne.config.remote_files
    end

end
