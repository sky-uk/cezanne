module Cezanne

  self::Config = Struct.new(:uid, :project_name, :local_root, :remote_root, :comparison_method) do 
    def initialize 
      self.local_root = 'artifacts'
      self.comparison_method = :phash_hamming_distance 
    end
  end
  
  def self.configure 
    require 'pry'
    binding.pry
    yield config if block_given?
  end
end
