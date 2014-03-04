require 'mechanize'

class GFAccessor

  GIRLFRIENDS_URL = 'http://vcard.ameba.jp'
  ACCESS_DEST = URI.parse(GIRLFRIENDS_URL)
  MY_AUTH_TOKEN = 'T1HqoifuLALvtoystecsjCOgPUmfeZBQUGW6ukKGydg0fdVxVGxjio3LnPcgZc9ya94CzJMTZweMcCW2KWpZIAkiaMYWjJrx9lgy'
  FILTER_BY_GIRLS = 1.to_s
  COOKIE_OPTION = {:domain => ACCESS_DEST.host, :expires => Time.now + 86400, :path => '/' }
  USER_AGENT_IPHONE = 'iPhone'

  def initialize
    @client = initialize_mechanize
    @db = GFDatabase.new
  end

  def clean
    @db.clean
  end

  def list
    @db.all
  end

  def persist
    @db.clean

    giftbox_url = "#{GIRLFRIENDS_URL}/giftbox"
    @client.get(giftbox_url)

    max_page = @client.page.at("span[@id='maxPage']").text.to_i

    max_page.times do |i|
      @client.get("#{giftbox_url}?page=#{i + 1}")
      @client.page.at("section[@class='underShadow']").children.each do | child |

        image_src = child.at("section/p/img")['src']

        name_with_rarity = child.at("section/dl/dt/span").text
        name = name_with_rarity.slice(0 .. name_with_rarity.index("(") - 1)
        rarity = name_with_rarity.slice(
          name_with_rarity.index("(") + 1 ..
          name_with_rarity.index(")") - 1
        )
        @db.save(name, rarity, image_src)
      end
    end
    @db.close
  end

private
  def initialize_mechanize
    Mechanize.new { |agent|
      agent.user_agent_alias = USER_AGENT_IPHONE

      filter_cookie = Mechanize::Cookie.new('giftBox-filter', FILTER_BY_GIRLS, COOKIE_OPTION)
      agent.cookie_jar.add ACCESS_DEST, filter_cookie

      auth_cookie = Mechanize::Cookie.new('gameAuthId', MY_AUTH_TOKEN, COOKIE_OPTION)
      agent.cookie_jar.add ACCESS_DEST, auth_cookie
    }
  end
end
