require "cezanne/version"
require "cezanne/local_files"
require "cezanne/remote_files"
require "cezanne/image"
require "cezanne/comparison"

module Cezanne

  def check_visual_regression_for page_name
    screenshot = take_screenshot page_name
    reference_screenshot = get_reference_screenshot_for page_name

    unless reference_screenshot
      mark_as_new screenshot
      raise "new screenshot for #{page_name}"
    end

    if spot_differences_between screenshot, reference_screenshot
      mark_for_review screenshot
      raise "screenshot for #{page_name} didn't match"
    end

    return true
  end

  private 

    def take_screenshot page_name
      path = File.join( local_files.path_for(:tmp), file_name_for(page_name) )
      page.driver.browser.save_screenshot(path)
      Cezanne::Image.new(path)
    end


    def get_reference_screenshot_for page_name
      path = File.join( local_files.path_for(:ref), file_name_for(page_name) )
      return false unless File.exists? path
      Cezanne::Image.new(path)
    end

    def spot_differences_between this, that
      width = [this.width, that.width].min
      height = [this.height, that.height].min
      [this, that].each { |img| img.crop!(width, height) }
      this.picture.compare_channel(that.picture, Magick::PeakSignalToNoiseRatioMetric)[1] < SIMILARITY_THRESHOLD
    end

    def file_name_for page_name
      "#{page_name}_#{page.driver.browser.browser.to_s}.gif"
    end

    def mark_as_new screenshot
      FileUtils.mv(screenshot.path, local_files.path_for(:new))
    end

    def mark_for_review screenshot
      FileUtils.mv(screenshot.path, local_files.path_for(:diff))
    end

end
