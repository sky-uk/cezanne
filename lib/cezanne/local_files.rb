module Cezanne

  class LocalFiles

    def initialize uid, base_path

      @folders = {
        ref: File.join(base_path, 'reference_screenshots'),
        diff: File.join(base_path, uid, 'different_screenshots'),
        new: File.join(base_path, uid, 'new_screenshots'),
        tmp: File.join(base_path, uid, 'tmp_screenshots')
      }

      @folders.each { |key, path| setup_directory_for key }

    end

    def path_for key
      @folders[key]
    end

    def clean
      path = File.dirname( path_for(:ref) )
      FileUtils.rm_rf path
    end

    private

      def setup_directory_for key
        FileUtils.rm_rf path_for(key)
        FileUtils.mkdir_p path_for(key)
      end

  end

end
