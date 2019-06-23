require 'selenium-webdriver'
require 'nokogiri'
require 'io/console'
require 'rmagick'
require 'json'
require 'twitter'
require "securerandom"

@wait_time = 3
@timeout = 4

@client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ""
    config.consumer_secret     = ""
    config.access_token        = ""
    config.access_token_secret = ""
end

#三次元配列を初期化`
@database = Hash.new { |hash, key| hash[key] = Hash.new{ |hash, key| hash[key] = Hash.new{} } }

File.open("./test.json" , "r") do |text|
    @database = JSON.parse(text.read.to_s, symbolize_names: true)
end

num = @database.length

#puts "学籍番号を入力"

#USERID = gets.chomp

USERID = ''

#puts "パスワードを入力"

#PASSWORD = STDIN.noecho(&:gets).chomp

PASSWORD = ""


puts "ユーザーIDとパスワードでログイン中"
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
driver = Selenium::WebDriver.for :chrome, options: options

Selenium::WebDriver.logger.output = File.join("./", "selenium.log")
Selenium::WebDriver.logger.level = :warn
#Selenium::WebDriver::Chrome::Binary.path = '/usr/local/bin/chromedriver'
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

all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea"]/ul/li[3]')
all_btn.click


puts "ログインに成功しました"
puts "タスク１を実行"

#タブ切り替え


#ダブってないかチェック
def cheak(str_title,str_data)
    @database.each do |target|
        if target[1][:title] == str_title then
            if target[1][:data] == str_data then
#             puts "[スキップ]:#{target[1][:title]} : #{target[1][:data]}"
                return true
            end
        end
    end
    return false
end


#軽視開始順に切り替え
#sleep(1)
sleep(1)
all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea:2:j_idt347"]/div[2]')
all_btn.click

all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea:2:order:j_idt332:0:j_idt334"]/div[3]')
all_btn.click

all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea:2:order:j_idt332:0:j_idt334_panel"]/div/ul/li[1]')
all_btn.click

#sleep(1)
all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea:2:j_idt347"]/div[2]')
all_btn.click

#sleep(3)
all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea:2:j_idt399"]/span')
all_btn.click

sleep(1)

doc = Nokogiri::HTML.parse(driver.page_source)

target = doc.xpath ('//*[@id="funcForm:tabArea:1:allScr"]')
target = Nokogiri::HTML.parse(target.to_s)

puts "更新を待機中"


target.xpath('//*[@id="keiji"]').each do |keiji|

    maintarget = Nokogiri::HTML.parse(keiji.to_s)
#    puts keiji.xpath('.//a').text.chomp
    if cheak(keiji.xpath('.//a').text.chomp,maintarget.xpath('//*[@id="keiji"]/text()').text.chomp.gsub(" ", "").gsub("\n", "")) then
        next
    end

    num = num + 1
    @database.store(num.to_s,{"title":keiji.xpath('.//a').text.chomp,"data":maintarget.xpath('//*[@id="keiji"]/text()').text.chomp.gsub(" ", "").gsub("\n", ""),"status":0,"type":"class"})

end
puts "完了 [#{num}件]"
puts "タスク２を実行"
sleep(1)

all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea"]/ul/li[2]')
all_btn.click

all_btn = driver.find_element(:xpath, '//*[@id="funcForm:tabArea:1:j_idt399"]/span')
all_btn.click
sleep(1)
doc2 = Nokogiri::HTML.parse(driver.page_source)

target2 = doc2.xpath ('//*[@id="funcForm:tabArea:1:allScr"]')
target2 = Nokogiri::HTML.parse(target2.to_s)

puts "更新を待機中"

target2.xpath('//*[@id="keiji"]').each do |keiji2|

    maintarget2 = Nokogiri::HTML.parse(keiji2.to_s)
#    puts keiji2.xpath('.//a').text.chomp
    if cheak(keiji2.xpath('.//a').text.chomp,maintarget2.xpath('//*[@id="keiji"]/text()').text.chomp.gsub(" ", "").gsub("\n", "")) then
        next
    end

    num = num + 1
    @database.store(num.to_s,{"title":keiji2.xpath('.//a').text.chomp,"data":maintarget2.xpath('//*[@id="keiji"]/text()').text.chomp.gsub(" ", "").gsub("\n", ""),"status":0,"type":"ALL"})

end


puts "取得完了 [#{num}件]"

def tweet(str_title,str_data,str_type)
    img = Magick::ImageList.new("./tile.png")
    draw = Magick::Draw.new

    str_desc = ""

    if str_type == "ALL" then
        str_desc = "全体向けのお知らせ"
    else
        str_desc = "授業に関するお知らせ"
    end

    str_tweet = "新しいお知らせが投稿されました\n#{str_desc}\n#{str_title}"

    if str_title.length >= 25 then
        str_title = "#{str_title.slice(0, 23)}..."
    end

    draw.annotate(img, 0, 0, 0, 0,str_title) do
        self.font      = './NotoSansCJKjp-Bold.otf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 70
        self.gravity   = Magick::CenterGravity
    end

    draw.annotate(img, 0, 0, 260, 180,"#{str_desc}:#{str_data}") do
        self.font      = './NotoSansCJKjp-Bold.otf'
        self.fill      = '#4b4b4b'
        self.stroke    = 'transparent'
        self.pointsize = 45
        self.gravity   = Magick::NorthWestGravity
    end

    #img.display
    img.write("./tweet.png")
    image = []
    image << File.new('./tweet.png')

    @client.update_with_media(str_tweet, image)

end

@database.each do |target|
    if target[1][:status] == 0 then
        tweet(target[1][:title],target[1][:data],target[1][:type])
        target[1][:status] = 1
    end
end

file = File.open('test.json', "w")

file.puts @database.to_json

driver.quit
