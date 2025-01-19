class Stop < ApplicationRecord
  has_many :routes_stops
  has_many :routes, through: :routes_stops

  def arrivals
    r = RestClient.get("http://telematics.oasa.gr/api/?act=getStopArrivals&p1=#{code}")
    arrivals = JSON.parse(r.body)
    return [] if arrivals.blank?

    arrivals.map do |arrival|
      { "line_code" => Route::ROUTE_CODE_TO_LINE_IDS[arrival["route_code"]] }.
        merge(arrival)
    end
  end
end
