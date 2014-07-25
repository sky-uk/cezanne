require 'RMagick'

module Cezanne

  class Image
    attr_reader :path, :picture

    def initialize path
      @path = path
      @picture = Magick::Image.read(@path).first
    end

    def crop! coords
      @picture.crop!(*coords)
    end

  end

end
