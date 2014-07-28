require 'spec_helper'
require 'pry'

class Dummy
end

describe Cezanne do

  before(:all) do

    @dummy = Dummy.new
    @dummy.extend Cezanne

    class Dummy
      def local_files
        @local_files ||= Cezanne::LocalFiles.new 'test', 'spec/artifacts/'
      end
      def remote_files
        @remote_files ||= Cezanne::RemoteFiles.new 'test', 'cezanne'
      end
    end

  end

  before(:each) do

    @page = double('page')
    driver = double('driver')
    browser = double('browser')
    allow(driver).to receive('browser').and_return(browser)
    allow(@page).to receive('driver').and_return(driver)
    allow(@dummy).to receive('page').and_return(@page)

  end

  it '#take_screenshot' do 
    expect(page.driver.browser).to receive('save_screenshot').with(/saintevictoire/)
    
  end




  context 'succesful match' do

    before(:each) do 
      FileUtils.cp('spec/saintevictoire_1.gif', File.join(@dummy.local_files.path_for(:ref), 'saintevictoire_success.gif'))
      allow(@page.driver.browser).to receive('browser').and_return(:success)
      allow(@page.driver.browser).to receive('save_screenshot').and_return(FileUtils.cp('spec/saintevictoire_1.gif', File.join(@dummy.local_files.path_for(:tmp), 'saintevictoire_success.gif')))
    end

    it '#check_visual_regression_for' do
      expect { @dummy.check_visual_regression_for 'saintevictoire' }.not_to raise_error
    end

  end

  context 'failed match' do

    before(:each) do
      FileUtils.cp('spec/saintevictoire_1.gif', File.join(@dummy.local_files.path_for(:ref), 'saintevictoire_fail.gif'))
      allow(@page.driver.browser).to receive('browser').and_return(:fail)
      allow(@page.driver.browser).to receive('save_screenshot').and_return(FileUtils.cp('spec/saintevictoire_2.gif', File.join(@dummy.local_files.path_for(:tmp), 'saintevictoire_fail.gif')))
    end

    it '#check_visual_regression_for' do
      expect { @dummy.check_visual_regression_for('saintevictoire') }.to raise_error(/didn't match/)
    end

  end

 
end
