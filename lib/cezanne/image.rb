require 'RMagick'

module Cezanne

  class Image
    attr_reader :path, :picture

    def initialize path, opts
      @path = path
      @picture = Magick::Image.read(@path).first
      if opts[:crop] 
        crop! *opts[:crop]
      end
    end

    def crop! *coords
      if coords.length == 2 then coords = [0, 0, *coords] end # treat them as widht and height
      coords.push true # get rid of offset after cropping :)
      @picture.crop!(*coords)
      @picture.write(@path)
    end

    def width
      @picture.columns
    end

    def height
      @picture.rows
    end
  end

end
