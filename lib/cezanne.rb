require "cezanne/version"
require "cezanne/local_files"
require "cezanne/remote_files"
require "cezanne/image"

module Cezanne

  SIMILARITY_THRESHOLD = 42

  def self.init uid, local_base_path = 'artifacts', remote_base_path = 'cezanne'
    @local_files = Cezanne::LocalFiles.new uid, local_base_path
    @remote_files = Cezanne::RemoteFiles.new uid, remote_base_path
    @remote_files.pull(:ref, @local_files.path_for(:ref))
  end


  def self.push_and_clean
    [:new, :diff].each do |key|
      remote_files.push(local_files.path_for(key), key)
    end
    local_files.clean
  end

  def check_visual_regression_for page_name
    screenshot = take_screenshot page_name
    reference_screenshot = get_reference_screenshot_for page_name

    unless reference_screenshot
      mark_as_new screenshot
      fail "new screenshot for #{page_name}"
    end

    if spot_differences_between screenshot, reference_screenshot
      mark_for_review screenshot
      fail "screenshot for #{page_name} didn't match"
    end

  end

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
    # crop to same size
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
