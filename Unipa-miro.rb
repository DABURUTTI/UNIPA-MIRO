require 'selenium-webdriver'
require 'nokogiri'

@wait_time = 3
@timeout = 4

USERID = gets.chomp
PASSWORD = gets.chomp

puts "ユーザーIDとパスワードでログイン中"

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
driver = Selenium::WebDriver.for :chrome, options: options

Selenium::WebDriver.logger.output = File.join("./", "selenium.log")
Selenium::WebDriver.logger.level = :warn

driver.manage.timeouts.implicit_wait = @timeout
wait = Selenium::WebDriver::Wait.new(timeout: @wait_time)

driver.get('https://portal.sa.dendai.ac.jp/uprx/')

puts "接続中"

search_box = driver.find_element(:id, 'loginForm:userId')
search_box2 = driver.find_element(:id, 'loginForm:password')
search_btn = driver.find_element(:id, 'loginForm:loginButton')

search_box.send_keys USERID
search_box2.send_keys PASSWORD
search_btn.click


#sleep(1)
all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea"]/ul/li[3]')
all_btn.click

puts "タスク１を実行"

#タブ切り替え

#軽視開始順に切り替え
sleep(1)
all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea:2:order:j_idt332:0:j_idt334"]/div[3]')
all_btn.click

all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea:2:order:j_idt332:0:j_idt334_panel"]/div/ul/li[1]')
all_btn.click

sleep(1)
all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea:2:j_idt347"]/div[2]')
all_btn.click

sleep(3)
all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea:2:j_idt399"]/span')
all_btn.click


puts "タスク２を実行"

sleep(3)
doc = Nokogiri::HTML.parse(driver.page_source)

m = 0

target = doc.xpath ('//*[@id="funcForm:tabArea:1:allScr"]')
target = Nokogiri::HTML.parse(target.to_s)

puts "更新を待機中"

target.xpath('//*[@id="keiji"]').each do |keiji|

    m = m + 1
    puts "No.#{m}: #{keiji.xpath('.//a').text}"

    sleep(0.03)

end

puts "完了 [#{m}件]"

driver.quit
