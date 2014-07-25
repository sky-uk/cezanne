require 'dropscreen'

module Cezanne

  class RemoteFiles

    def initialize uid, base_path
      @remote_folders = {
        ref: File.join('reference_screenshots'),
        diff: File.join(uid, 'different_screenshots'),
        new: File.join(uid, 'new_screenshots')
      }

      @adapter = Dropscreen::Client.new( remote_base_dir: base_path, local_base_dir: './' )
    end

    def pull key, path
      @adapter.pull @remote_folders[key], path
    end

    def push path, key
      @adapter.push path, @remote_folders[key]
    end

  end

end
