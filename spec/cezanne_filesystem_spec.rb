require 'spec_helper'

describe Cezanne::LocalFiles do 
  
  before(:each) do
    @local_files = Cezanne::LocalFiles.new 'test', 'spec/artifacts' 
  end
  
  describe '#initialize' do

    it 'create local folders for the screenshots' do
      expect(File.exists?('spec/artifacts/reference_screenshots')).to be true
      expect(File.exists?('spec/artifacts/test/different_screenshots')).to be true
      expect(File.exists?('spec/artifacts/test/new_screenshots')).to be true
    end

  end
  
  describe '#path_for' do

    it 'is a path helper' do  
      [:ref, :diff, :new, :tmp].each do |key|
        expect(@local_files.path_for(key)).to eq(@local_files.instance_variable_get(:@folders)[key])
      end
    end

  end

  describe '#clean' do

    it 'remove all local folders' do
      @local_files.clean 
      expect(File.exists?('spec/artifacts/local_files_test')).to be false
    end

  end
  
  after(:each) do
    FileUtils.rm_rf 'spec/artifacts/local_files_test'
  end

end

describe Cezanne::RemoteFiles do
 
  let(:dropscreen_client) { double('Dropscreen::Client') }

  before(:each) do 
    allow(Dropscreen::Client).to receive('new').and_return(dropscreen_client)  
    @remote_files = Cezanne::RemoteFiles.new 'test_uid', 'cezanne'
  end

  describe '#pull' do

    it 'is a proxy to Dropscreen::Client#pull' do
      expect(dropscreen_client).to receive(:pull).at_least(1).times.with(kind_of(String), 'local_path')  
      [:ref, :diff, :new].each do |key|
        @remote_files.pull key, 'local_path'
      end 
    end

  end

  describe '#push' do
    
    it 'is a proxy to Dropscreen::Client#push' do
      expect(dropscreen_client).to receive(:push).at_least(1).times.with('local_path', kind_of(String))  
      [:ref, :diff, :new].each do |key|
        @remote_files.push 'local_path', key 
      end
    end 
  end
  
end

