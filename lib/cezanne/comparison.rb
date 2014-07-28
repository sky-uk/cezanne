require 'RMagick'

module Cezanne

  SIMILARITY_THRESHOLD = 42

  def spot_differences_between this, that
    width = [this.width, that.width].min
    height = [this.height, that.height].min
    [this, that].each { |img| img.crop!(width, height) }
    this.picture.compare_channel(that.picture, Magick::PeakSignalToNoiseRatioMetric)[1] < SIMILARITY_THRESHOLD
  end

end
