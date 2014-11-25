require 'RMagick'
require 'open3'

module Cezanne

  SIMILARITY_THRESHOLD = 0.0

  def spot_differences_between this, that, diff
    width = [this.width, that.width].min
    height = [this.height, that.height].min
    [this, that].each { |img| img.crop!(width, height) }

    cmdline = "compare -dissimilarity-threshold 1 -fuzz 20% -metric AE -highlight-color blue \"#{this.path}\" \"#{that.path}\" \"#{diff}\""
    px_value = Open3.popen3(cmdline) { |_stdin, _stdout, stderr, _wait_thr| stderr.read }.to_f
    px_value > SIMILARITY_THRESHOLD
  end

end
