require 'spec_helper'

describe Cezanne do

  let(:class_with_cezanne) { Class.include(Cezanne).new }
  # Capybara mocks
  let(:page) { double('page') }
  let(:driver) { double('driver') }
  let(:browser) { double('browser') }
  # RMagick mocks
  let(:picture) { double('Magick::Image') }
  # Cezanne classes mocks
  let(:local_files) { double('local_files') }
  let(:image) { double('Cezanne::Image') }

  before(:each) do
    allow(browser).to receive('browser').and_return(:browser)
    allow(browser).to receive('save_screenshot')
    allow(driver).to receive('browser').and_return(browser)
    allow(page).to receive('driver').and_return(driver)
    allow(local_files).to receive('path_for').and_return('spec/artifacts')
    allow(class_with_cezanne).to receive('page').and_return(page)
    allow(class_with_cezanne).to receive('local_files').and_return(local_files) 
    allow(class_with_cezanne).to receive('image').and_return(image)
  end

  describe '#take_screenshot' do

    it 'take a screenshot using the browser driver' do
      expect(page.driver.browser).to receive('save_screenshot')   
      class_with_cezanne.send(:take_screenshot, 'page_name')
    end
    
    it 'return a Cezanne::Image' do
      expect(class_with_cezanne.send(:take_screenshot, 'page_name')).to be image
    end
    
  end
  
  describe '#get_reference_screenshot_for' do 

    it 'return the reference Cezanne::Image' do
      expect(class_with_cezanne.send(:get_reference_screenshot_for, 'page_name')).to be image
    end

    it 'return false if the reference image does not exist' do 
      expect(class_with_cezanne.send(:get_reference_screenshot_for, 'page_name_with_no_reference')).to be false
    end

  end

  describe '#spot_differences_between' do 
    
    let(:this) { image }
    let(:that) { this.clone }

    before(:each) do
      allow(image).to receive('picture').and_return(picture)
      allow(image).to receive('crop!')
      allow(picture).to receive('compare_channel').with(picture, Magick::PeakSignalToNoiseRatioMetric).and_return([nil, 1]) 
      allow(this).to receive('width').and_return(1)
      allow(this).to receive('height').and_return(2)
      allow(that).to receive('width').and_return(2)
      allow(that).to receive('height').and_return(1)
    end

    it 'crop images to min width and height' do 
      expect(this).to receive('crop!').with(1,1)
      expect(that).to receive('crop!').with(1,1)
      class_with_cezanne.send(:spot_differences_between, this, that)
    end
  
    context 'similar images' do
      
      it 'return false' do
        expect(this.picture).to receive('compare_channel').and_return([nil, Cezanne::SIMILARITY_THRESHOLD + 1]) 
        expect(class_with_cezanne.send(:spot_differences_between, this, that)).to be false 
      end
    
    end
    
    context 'different images' do
      
      it 'return true' do
        expect(this.picture).to receive('compare_channel').and_return([nil, Cezanne::SIMILARITY_THRESHOLD - 1]) 
        expect(class_with_cezanne.send(:spot_differences_between, this, that)).to be true 
      end
    
    end
  end

  describe '#file_name_for' do

    it 'contains page_name and browser' do
      expect(class_with_cezanne.send(:file_name_for, 'fancy_page_name')).to eq('fancy_page_name_browser.gif')
    end
  
  end

  describe '#mark_for_review' do
    
    let(:screenshot) { image }

    before(:each) do
      allow(image).to receive('path').and_return('spec/artifacts/page_name_browser.gif')    
    end 

    it 'moves screenshot to the diff folder' do
      expect(local_files).to receive('path_for').with(:diff).and_return('spec/artifacts/different.gif')
      class_with_cezanne.send(:mark_for_review, screenshot)
      expect(File.exists?('spec/artifacts/different.gif')).to be true
    end

    after(:each) do
      FileUtils.mv('spec/artifacts/different.gif', 'spec/artifacts/page_name_browser.gif')
    end

  end


  describe '#mark_as_new' do
    
    let(:screenshot) { image }

    before(:each) do
      allow(image).to receive('path').and_return('spec/artifacts/page_name_browser.gif')    
    end 

    it 'moves screenshot to the new folder' do
      expect(local_files).to receive('path_for').with(:new).and_return('spec/artifacts/new.gif')
      class_with_cezanne.send(:mark_as_new, screenshot)
      expect(File.exists?('spec/artifacts/new.gif')).to be true
    end

    after(:each) do
      FileUtils.mv('spec/artifacts/new.gif', 'spec/artifacts/page_name_browser.gif')
    end

  end
  describe '#check_visual_regression_for' do

    before(:each) do
      allow(class_with_cezanne).to receive('get_reference_screenshot_for').and_return(Cezanne::Image.new('spec/artifacts/page_name_browser.gif'))
    end

    context 'succesful match' do

      it 'does not raise an error' do
        allow(class_with_cezanne).to receive('take_screenshot').and_return(Cezanne::Image.new('spec/artifacts/page_name_browser.gif'))
        expect { class_with_cezanne.check_visual_regression_for 'page_name' }.not_to raise_error
      end

    end

    context 'failed match' do

      let(:screenshot) { Cezanne::Image.new('spec/artifacts/page_name_2_browser.gif') }

      before(:each) do
        allow(class_with_cezanne).to receive('take_screenshot').and_return(screenshot)
        allow(class_with_cezanne).to receive('mark_for_review')
      end

      it 'raise a <did not match> error' do
        expect { class_with_cezanne.check_visual_regression_for('page_name') }.to raise_error(/didn't match/)
      end

      it 'mark the screenshot for review' do
        expect(class_with_cezanne).to receive('mark_for_review').with(screenshot)
        begin 
          class_with_cezanne.check_visual_regression_for('page_name') 
        rescue 
        end
      end
    end 

    context 'new screenshot' do 

      let(:screenshot) { Cezanne::Image.new('spec/artifacts/page_name_browser.gif') }

      before(:each) do
        allow(class_with_cezanne).to receive('get_reference_screenshot_for').and_return(false)
        allow(class_with_cezanne).to receive('take_screenshot').and_return(screenshot)
        allow(class_with_cezanne).to receive('mark_as_new')
      end

      it 'raise a <new> error' do
        expect { class_with_cezanne.check_visual_regression_for('page_name') }.to raise_error(/new screenshot/)
      end
      
      it 'mark the screenshot as new' do
        expect(class_with_cezanne).to receive('mark_as_new').with(screenshot) 
        begin
          class_with_cezanne.check_visual_regression_for('page_name')
        rescue
        end
      end

    end
  end
end
