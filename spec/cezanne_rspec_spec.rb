require 'cezanne/rspec'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'pry'


Capybara.app = Rack::Directory.new('spec/images')
Capybara.default_driver = :selenium

RSpec.configure do |config|
  config.include Cezanne
  config.cezanne = { uid: 'test', project_name: 'cezanne' }
end

describe 'Cezanne RSpec integration', type: :feature, screenshots: true, integration: true do
 
  # wrap each test with before(:all) and after(:all) 

  after(:all) do |example|
    RSpec.configuration.after(:all, screenshots: true).last.instance_variable_set(:@block, Proc.new {}) # disable the after(:all) hook  
  end

  before(:each) do |example|
    RSpec.configuration.before(:all, screenshots: true).first.run(example) 
  end

  after(:each) do |example|
    RSpec.configuration.after(:all, screenshots: true).last.run(example) unless example.metadata[:after_hook_test] 
  end






  describe 'initialization' do
   
    it 'create local folders' do 
      expect(File.exist?('artifacts/reference_screenshots')).to be true
      expect(File.exist?('artifacts/test/tmp_screenshots')).to be true 
      expect(File.exist?('artifacts/test/different_screenshots')).to be true 
      expect(File.exist?('artifacts/test/new_screenshots')).to be true 
    end
 

    it 'pull reference_screenshots' do 
      expect(File.exist?('artifacts/reference_screenshots/similar_firefox.gif')).to be true
      expect(File.exist?('artifacts/reference_screenshots/different_firefox.gif')).to be true
    end
 
  end 
  
  describe 'take screenshots' do 

    context 'similar' do

      it 'pass the test' do
        visit '/similar.html'
        expect { check_visual_regression_for 'similar' }.not_to raise_error
      end

    end
    
    context 'different' do

      it 'fail the test' do
        visit '/different.html'
        expect { check_visual_regression_for 'different' }.to raise_error
      end

    end

    
    context 'new' do

      it 'fail the test' do
        visit '/new.html'
        expect { check_visual_regression_for 'new' }.to raise_error
      end

    end
  
  end

  describe 'finalization', after_hook_test: true do
    
    it 'push new, diff screenshots to remote' do |example|
      expect(RSpec.configuration.cezanne[:remote_files]).to receive('push').with(kind_of(String), :diff).and_call_original
      expect(RSpec.configuration.cezanne[:remote_files]).to receive('push').with(kind_of(String), :new).and_call_original
      RSpec.configuration.after(:all, screenshots: true).last.run(example)  
    end

    it 'clean local folders' do |example|
      RSpec.configuration.after(:all, screenshots: true).last.run(example)
      expect(File.exists?('artifacts')).to be false
    end

  end

end
