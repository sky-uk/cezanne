[![Build Status](https://travis-ci.org/bskyb-commerce/cezanne.svg?branch=master)](https://travis-ci.org/bskyb-commerce/cezanne)

# Cezanne

Visual regression testing tool

## Installation

Add this line to your application's Gemfile:

    gem 'cezanne'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cezanne

## Usage - RSpec

In your spec_helper.rb
    
    require 'cezanne/rspec'
    
    RSpec.configure do |config|
      config.include Cezanne
      config.cezanne = { uid: ENV['build_number'], project_name: 'awesome_app' }
    end

The uid should be a unique identifier. We use the build number, but it can be a static string if you don't need
to keep multiple versions of the screenshots.

In your tests

    
    describe 'Mont Sainte-Victoire', screenshots: true do
      it 'is a masterpiece' do
        visit 'url-to-painting'
        check_visual_regression_for 'mont-sainte-victoire'
      end
    end

Make sure to use a unique name for each screenshot. 
The associate file will be a gif image named after the parameter ('mont-sainte-victoire' in the example above)
and the browser name, to make it easy to check visual regressions on multiple browsers.

## Dependencies

Cezanne uses ImageMagick to compare images. Check with your package manager.

Screenshots are stored on Dropbox through the Dropscreen gem. Follow the instructions at https://github.com/bskyb-commerce/dropscreen and make sure to export the access_token

    export DROPBOX_ACCESS_TOKEN=**insert dropbox access token here**

Screenshots are taken using Capybara.

## (Opinionated) Workflow

* Reference screenshots are stored on Dropbox
* New and different screenshots will be synced to Dropbox at the end of the test suite 


    ```
    project_name
    |
    +-- reference_screenshots
    |
    +-- uid
    |   |
    |   +-- new_screenshots
    |   |
    |   +-- different_screenshots
    |
    |
    +-- uid_2
        |
        ...
    ```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/cezanne/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

Made with <3 by the Sky Haiku team
