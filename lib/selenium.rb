require 'selenium-webdriver'
require 'logger'

class Selenium_driver

  def initialize
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.add_extension 'extensions/JSErrorCollector.xpi' rescue p "Cannot add JSErrorCollector.xpi to profile"
    @driver = Selenium::WebDriver.for :firefox, :profile => profile

    @timer = Selenium::WebDriver::Wait.new(:timeout => 60)
    @logger = Logger.new('logs/log.txt')
    @logger.level = Logger::INFO
    @errors = 0
  end

  def init(url)
    @url = url
    @errors = 0
    @driver.navigate.to url
    self.start_log
  end

  def find_single_element(h = {})
    begin
      p h[:attr]
      item = @driver.find_element(h[:attr],h[:value])
      if item.displayed?
        item.send_keys(h[:send_keys]) if h[:send_keys]
        item.click if h[:click]
      end
    rescue Exception
      self.error_log(h)
      false
    end
  end

  def wait(h = {})
    begin
      t = @timer
      t.until{@driver.find_element(h[:attr],h[:value])}
    rescue Exception
      self.error_log(h)
      false
    end
  end

  def wait_for_count(h = {})
    begin
      t = @timer
      #Refactor this
      #t.until{@driver.find_elements(h[:attr],h[:value]).length << h[:operator] << h[:length]}
      t.until{@driver.find_elements(h[:attr],h[:value]).length > 2}
    rescue Exception
      self.error_log(h)
      false
    end
  end

  def error_log(o = {})
    @errors = 1
    @logger.error("Site: #{@url}: Can't find element with #{o[:attr]}:#{o[:value]}, skipping test.")
  end

  def info_log(o = {})
    @logger.info("#{o[:message]}")
  end

  def close_logger
    self.info_log({:message => "-----------------------------------------------------------------------"})
    @logger.close
  end

  def check_errors
    @errors
  end

  def start_log
    self.info_log({:message => "-----------------------------------------------------------------------"})
    self.info_log({:message => "Testing for #{@url} is started..."})
  end

  #Function that returns a string that presents the details of the occurred JS errors
  def get_js_error_feedback
    jserror_descriptions = ""
    begin
      jserrors = @driver.execute_script("return window.JSErrorCollector_errors.pump()")
      jserrors.each do |jserror|
        @logger.debug "ERROR: JS error detected:\n#{jserror["errorMessage"]} (#{jserror["sourceName"]}:#{jserror["lineNumber"]})"

        jserror_descriptions += "JS error detected:
   #{jserror["errorMessage"]} (#{jserror["sourceName"]}:#{jserror["lineNumber"]})
"
      end
    rescue Exception => e
      @logger.debug "Checking for JS errors failed with: #{e.message}"
    end
    jserror_descriptions
  end
end