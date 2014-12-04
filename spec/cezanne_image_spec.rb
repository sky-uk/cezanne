require 'spec_helper'

describe Cezanne::Image do

  let(:image) { Cezanne::Image.new('spec/images/page_name_browser_version.gif', {}) }


  describe '#initialize' do 
    
    it 'wraps Magick::Image' do
      expect(image.picture).to be_instance_of(Magick::Image)    
    end

    it 'return an error if there is no file at path' do
      expect { Cezanne::Image.new('inexistent_file_path') }.to raise_error
    end
  end
  
  describe '#width' do

    it 'has a width' do
      expect(image.width).to be 712
    end

  end

  describe '#height' do

    it 'has a height' do
      expect(image.height).to be 599
    end

  end
  
  describe '#crop!' do

    before(:each) do
      FileUtils.cp('spec/images/page_name_browser_version.gif', 'spec/images/page_name_browser_version.bak')
    end

    it 'accepts 4 parameters x, y, width, height' do
      x = 1
      y = 2
      width = 5
      height = 10
      image.crop!(x,y,width,height)
      expect(image.width).to be 5 
      expect(image.height).to be 10   
    end
 
    it 'accepts width and height alone' do
      width = 10
      height = 5
      image.crop!(width, height)
      expect(image.width).to be 10
      expect(image.height).to be 5
    end

    it 'write the cropped image to disk' do
      expect(image.picture).to receive(:write)
      image.crop!(10,10)
    end

    after(:each) do
      FileUtils.mv('spec/images/page_name_browser_version.bak', 'spec/images/page_name_browser_version.gif', force: true)
    end

  end

  describe '#duplicate?' do 
    let(:other_image) { double('Cezanne::Image') }

    it 'compare two images' do 
      Cezanne.config.comparison_method = :comparison_method
      allow(image).to receive(:comparison_method)
      expect(image).to receive(:comparison_method).with(other_image)
      image.duplicate? other_image
    end 

    it 'can use peak signal to noise ratio' do 
      Cezanne.config.comparison_method = :peak_signal_to_noise_ratio
      allow(other_image).to receive(:picture)
      expect(image.picture).to receive(:compare_channel).with(other_image.picture, Magick::PeakSignalToNoiseRatioMetric).and_return([nil, 10])
      image.duplicate? other_image
    end

    it 'can use phash hamming distance' do 
      Cezanne.config.comparison_method = :phash_hamming_distance
      allow(other_image).to receive(:path)
      expect_any_instance_of(Phashion::Image).to receive(:duplicate?)
      image.duplicate? other_image
    end

  end
end
