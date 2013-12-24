require 'net/http'
require 'json'

module GiveByte
  def self.reset_rests
    save_rests(fetch_rests)
  end

  def self.get_rests
    load_rests()
  end

  def self.update_rests
    rests = get_rests()
    fetch_rests.each do |rest|
      rests[rest.id] ||= rest
      rests[rest.id]["is_expected"] ||= rest["pool_sum"] > 0
    end
    save_rests(rests)
  end

private

  RESTS_FILE = File.expand_path("../rests.json", __FILE__)

  def self.load_rests()
    JSON.parse(File.read RESTS_FILE) rescue {}
  end

  def self.save_rests(rests)
    File.write RESTS_FILE, rests.to_json
  end

  def self.fetch_rests
    http = Net::HTTP.new "www.10bis.co.il", 80
    headers = {
      "deliveryMethod" => "Delivery",
      "ShowOnlyOpenForDelivery" => "False",
      "id" => "942159",
      "pageNum" => "0",
      "pageSize" => "1000",
      "ShowOnlyOpenForDelivery" => "false",
      "OrderBy" => "delivery_sum",
      "cuisineType" => "",
      "StreetId" => "0",
      "FilterByKosher" => "false",
      "FilterByBookmark" => "false",
      "FilterByCoupon" => "false",
      "searchPhrase" => "",
      "Latitude" => "32.0696",
      "Longitude" => "34.7935",
      "timestamp" => "1387750840791"
    }
    headers_querystring = headers.reduce([]) {|acc, (k, v)| acc << %(#{k}=#{v})}.join("&")
    response = http.get "/Restaurants/SearchRestaurants?#{headers_querystring}", "Content-Type" => "application/json; charset=UTF-8"
    data = JSON.parse(response.body)
    rests = data.reduce({}) do |ans, rest|
      pool_sum = rest["PoolSum"][2..-1].to_i
      id = rest["RestaurantId"]
      ans[id] = {
        "name" => rest["RestaurantName"],
        "logo" => rest["RestaurantLogoUrl"],
        "id" => id,
        "pool_sum" => pool_sum,
        "is_expected" => pool_sum > 0
      }
      ans
    end

    rests
  end

end
