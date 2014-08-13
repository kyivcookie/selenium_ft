require_relative '../lib/selenium'

class ChatTest
  def initialize
    @sites = IO.read('sites/sites_test.txt')
    @array = @sites.split(',')
  end

  def run
    m = {
        :test_message => "This is a test",
        :close_chat   => "Please, close the chat",
        :email        => "andrey.pristupa@gubagoo.com"
    }
    @array.each do |s|
      d = Selenium_driver.new
      d.init(s)
      d.wait :attr => :id, :value => 'gubagooToolbar'
      d.find_single_element :attr => :class, :value => 'ggIconChat', :click => 1
      d.wait :attr => :id, :value => 'ggChatSubject'
      d.find_single_element :attr => :id, :value => 'ggChat_name', :send_keys => 'Test User', :skip_error => 1
      d.find_single_element :attr => :id, :value => 'ggChatSubject', :send_keys => m[:test_message]
      #d.find_single_element :attr => :id, :value => 'ggChat_start', :click => 1
      #d.wait :attr => :id, :value => 'ggChat_send'
      #d.wait_for_count :attr => :class, :value => 'gubagooMessage', :operator => '>', :length => 2
      #d.find_single_element :attr => :id, :value => 'ggChat_message', :send_keys => m[:close_chat]
      #d.find_single_element :attr => :id, :value => 'ggChat_send', :click => 1
      #d.wait :attr => :id, :value => 'ggChat_email'
      #d.find_single_element :attr => :id, :value => 'ggChat_email', :send_keys => m[:email]
      #d.find_single_element :attr => :id, :value => 'ggChat_send', :click => 1
      if d.check_errors == 1
        d.error_log :message => 'Test Failed'
      else
        d.info_log :message => 'Test OK'
      end
      d.end_test
    end
  end

  protected
  def debug
    p @sites
  end
end