require 'selenium-webdriver'
require 'logger'

class Selenium_driver

  def initialize
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.add_extension 'extensions/JSErrorCollector.xpi' rescue p "Cannot add JSErrorCollector.xpi to profile"
    @driver = Selenium::WebDriver.for :firefox, :profile => profile
    @timer = Selenium::WebDriver::Wait.new(:timeout => 6)
    @logger = Logger.new('logs/log_test.txt')
    @logger.level = Logger::INFO
    @errors = 0
  end

  def init(url)
    @url = url
    @errors = 0
    self.start_log
    begin
      @driver.manage.timeouts.implicit_wait = 20
      @driver.navigate.to url
    rescue Exception => e
      self.error_log({:message => "Failed to load url: #{@url}"})
      self.close(false, e)
    end
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
      self.close(h)
    end
  end

  def wait(h = {})
    begin
      t = @timer
      t.until{@driver.find_element(h[:attr],h[:value])}
    rescue Exception
      self.error_log(h)
      self.close(h)
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
      self.close(h)
    end
  end

  def error_log(o = {})
    @errors = 1
    if o[:message]
      @logger.error(o[:message])
      return true
    end
    @logger.error("Site: #{@url}: Can't find element with #{o[:attr]}:#{o[:value]}, skipping test.")
  end

  def info_log(o = {})
    @logger.info("#{o[:message]}")
  end

  def close(o = {}, exception = false)
    @errors = 1
    jserror = self.get_js_error_feedback
    if jserror
      self.info_log({:message => self.get_js_error_feedback})
    end
    if exception
      self.info_log({:message => exception.message})
    end
    self.info_log({:message => '-----------------------------------------------------------------------'})
    @logger.close
    #@driver.quit
  end

  def end_test
    @logger.close
    @driver.quit
  end

  def check_errors
    @errors
  end

  def start_log
    self.info_log({:message => '-----------------------------------------------------------------------'})
    self.info_log({:message => "Testing for #{@url} is started..."})
  end

  #Function that returns a string that presents the details of the occurred JS errors
  def get_js_error_feedback
    jserror_descriptions = ""
    begin
      jserrors = @driver.execute_script("return window.JSErrorCollector_errors.pump()")
      jserrors.each do |jserror|
        @logger.debug "ERROR: JS error detected:\n#{jserror['errorMessage']} (#{jserror['sourceName']}:#{jserror['lineNumber']})"
        jserror_descriptions += "JS error detected:#{jserror['errorMessage']} (#{jserror['sourceName']}:#{jserror['lineNumber']})
"
      end
    rescue Exception => e
      @logger.debug "Checking for JS errors failed with: #{e.message}"
    end
    jserror_descriptions
  end
end