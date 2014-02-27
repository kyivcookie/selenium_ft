require_relative '../lib/selenium'

class ChatTest
  def initialize
    @sites = IO.read('sites/sites.txt')
    @array = @sites.split(',')
    @driver = Selenium_driver.new
  end

  def run
    m = {
        :test_message => "This is a test",
        :close_chat   => "Please, close the chat",
        :email        => "andrey.pristupa@gubagoo.com"
    }
    d = @driver
    @array.each do |s|
      d.init(s)
      d.find_single_element :attr => :class, :value => 'ggIconChat', :click => 1
      d.wait :attr => :id, :value => 'ggChatSubject'
      d.find_single_element :attr => :id, :value => 'ggChatSubject', :send_keys => m[:test_message]
      d.find_single_element :attr => :id, :value => 'ggChat_start', :click => 1
      d.wait :attr => :id, :value => 'gg-chat-scroller'
      d.wait_for_count :attr => :class, :value => 'gubagooMessage', :operator => '>', :length => 2
      d.find_single_element :attr => :id, :value => 'ggChat_message', :send_keys => m[:close_chat]
      d.find_single_element :attr => :id, :value => 'ggChat_send', :click => 1
      d.wait :attr => :id, :value => 'ggChat_email'
      d.find_single_element :attr => :id, :value => 'ggChat_email', :send_keys => m[:email]
      d.find_single_element :attr => :id, :value => 'ggChat_send', :click => 1
      if d.check_errors == 1
        d.info_log :message => "TEST ERROR..."
        d.info_log :message => "JS Errors was detecded: #{d.get_js_error_feedback}"
      else
        d.info_log :message => "TEST OK..."
      end
    end
    d.close_logger
  end

  protected
  def debug
    p @sites
  end
end