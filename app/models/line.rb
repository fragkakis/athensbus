class Line < ApplicationRecord
  has_many :routes

  def itinerary
    r = RestClient::Request.execute(
      method: :get,
      url: "http://telematics.oasa.gr/api/?act=getDailySchedule&line_code=#{code}",
      timeout: 5)
    JSON.parse(r.body).presence || []
  end
end
