require 'spec_helper'

describe 'Cezanne Files' do 

  describe Cezanne::LocalFiles do
   it 'creates local folders for the screenshots' do
      Cezanne::LocalFiles.new 'test', 'spec/artifacts'
      expect(File.exists?('spec/artifacts/reference_screenshots')).to be true
      expect(File.exists?('spec/artifacts/test/different_screenshots')).to be true
      expect(File.exists?('spec/artifacts/test/new_screenshots')).to be true
    end

    after :each do
      FileUtils.rm_rf 'spec/artifacts'
    end

  end

  describe Cezanne::RemoteFiles do
    it '#pull' do
      local_files = Cezanne::LocalFiles.new 'test', 'spec/artifacts'
      remote_files = Cezanne::RemoteFiles.new 'test', 'cezanne'
      remote_files.pull(:ref, local_files.path_for(:ref))
      expect(File.exists?('spec/artifacts/reference_screenshots/saintevictoire_browser.gif')).to be true
    end

    xit '#push' do
      
    end

  end

  after :all do
    Cezanne::LocalFiles.new('test', 'spec/artifacts').clean
  end
end
