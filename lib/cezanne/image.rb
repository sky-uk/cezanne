require 'RMagick'

module Cezanne

  class Image
    attr_reader :path, :picture

    def initialize path
      @path = path
      @picture = Magick::Image.read(@path).first
    end

    def crop! *coords
      if coords.length == 2 then coords = [0, 0, *coords] end # treat them as widht and height
      @picture.crop!(*coords)
    end

    def width
      @picture.columns
    end

    def height
      @picture.rows
    end
  end

end
