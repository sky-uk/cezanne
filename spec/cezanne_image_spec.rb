require 'spec_helper'

describe Cezanne::Image do

  let(:image) { Cezanne::Image.new('spec/images/page_name_browser_version.gif') }

  describe '#initialize' do 
    
    it 'wraps Magick::Image' do
      expect(image.picture).to be_instance_of(Magick::Image)    
    end

    it 'return an error if there is no file at path' do
      expect { Cezanne::Image.new('unexistent_file_path') }.to raise_error
    end
  end
  
  describe '#width' do

    it 'has a width' do
      expect(image.width).to be 763
    end

  end

  describe '#height' do

    it 'has a height' do
      expect(image.height).to be 599
    end

  end
  
  describe '#crop!' do

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

  end
end
