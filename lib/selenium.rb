require 'selenium-webdriver'
require 'logger'

class Selenium_driver
  def initialize
    @driver = Selenium::WebDriver.for :firefox
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
    @logger.close
  end

  def check_errors
    @errors
  end

  def start_log
    self.info_log({:message => "-----------------------------------------------------------------------"})
    self.info_log({:message => "Testing for #{@url} is started..."})
    #self.info_log({:message => "-----------------------------------------------------------------------"})
  end
end