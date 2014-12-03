require 'RMagick'
require 'phashion'

module Cezanne

  class Image
    attr_reader :path, :picture

    def initialize path, opts = {}
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

    def duplicate? other
      send(Cezanne.config.comparison_method, other)
    end

    alias_method :==, :duplicate?
    
    private 

      def peak_signal_to_noise_ratio other
        similarity_threshold = 42
        @picture.compare_channel(other.picture, Magick::PeakSignalToNoiseRatioMetric)[1] > similarity_threshold
      end 

      def phash_hamming_distance other 
        similarity_threshold = 15
        Phashion::Image.new(@path).duplicate? Phashion::Image.new(other.path), threshold: similarity_threshold
      end 

  end
 
end
