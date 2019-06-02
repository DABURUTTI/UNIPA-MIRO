require 'selenium-webdriver'
require 'nokogiri'

@wait_time = 3
@timeout = 4

USERID = ''
PASSWORD = ''

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
driver = Selenium::WebDriver.for :chrome, options: options

Selenium::WebDriver.logger.output = File.join("./", "selenium.log")
Selenium::WebDriver.logger.level = :warn

driver.manage.timeouts.implicit_wait = @timeout
wait = Selenium::WebDriver::Wait.new(timeout: @wait_time)

driver.get('https://portal.sa.dendai.ac.jp/uprx/')

search_box = driver.find_element(:id, 'loginForm:userId')
search_box2 = driver.find_element(:id, 'loginForm:password')
search_btn = driver.find_element(:id, 'loginForm:loginButton')

search_box.send_keys USERID
search_box2.send_keys PASSWORD
search_btn.click

sleep(1)
all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea"]/ul/li[2]')
all_btn.click

sleep(1)
all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea:1:j_idt399"]/span')
all_btn.click

sleep(1)
doc = Nokogiri::HTML.parse(driver.page_source)

m = 0

target = doc.xpath ('//*[@id="funcForm:tabArea:1:allScr"]')
target = Nokogiri::HTML.parse(target.to_s)

target.xpath('//*[@id="keiji"]').each do |keiji|

    m = m + 1
    puts keiji.xpath('.//a').text

end

driver.quit
