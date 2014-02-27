require "selenium-webdriver"
require 'logger'
#require 'watir-webdriver'

m = {
    :test_message => "This is a test",
    :close_chat   => "Please, close the chat"
}

#profile = Selenium::WebDriver::Firefox::Profile.new
#profile.add_extension "extention/JSErrorCollector.xpi" rescue p "Cannot add JSErrorCollector.xpi to profile"
#$BROWSER = Watir::Browser.new 'firefox', :profile => profile
#$BROWSER.goto "http://www.gubagoo.com"

l = Logger.new('logs/log.txt')

d = Selenium::WebDriver.for :firefox
wait = Selenium::WebDriver::Wait.new(:timeout => 60)

d.navigate.to "http://gubagoo.com"


d.find_element(:class, 'ggIconChat').click

wait.until{d.find_element(:id, 'ggChatSubject')}

d.find_element(:id, 'ggChatSubject').send_keys(m[:test_message])

d.find_element(:id,'ggChat_start').click

wait.until{d.find_elements(:id,'gg-chat-scroller')}
wait.until{d.find_elements(:class, 'gubagooMessage').length > 2}

d.find_element(:id,'ggChat_message').send_keys(m[:close_chat])
d.find_element(:id,'ggChat_send').click

wait.until{d.find_element(:id,'ggChat_email')}
d.find_element(:id, 'ggChat_email').send_keys("andrey.pristupa@gubagoo.com")
d.find_element(:id, 'ggChat_send').click

puts d.title