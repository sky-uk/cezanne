module Cezanne

  def spot_differences_between this, that
    width = [this.width, that.width].min
    height = [this.height, that.height].min
    [this, that].each { |img| img.crop!(width, height) }

    not(this.duplicate? that)
  end

end
