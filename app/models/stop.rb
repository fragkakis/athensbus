class Stop < ApplicationRecord
  has_many :routes_stops
  has_many :routes, through: :routes_stops
  has_many :arrivals

  def pending_arrivals
    r = RestClient::Request.execute(method: :get,
                                    url: "http://telematics.oasa.gr/api/?act=getStopArrivals&p1=#{code}",
                                    timeout: 5)
    arrivals = JSON.parse(r.body)
    return [] if arrivals.blank?

    arrivals.map do |arrival|
      { "line_code" => Route::ROUTE_CODE_TO_LINE_IDS[arrival["route_code"]] }.
        merge(arrival)
    end
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error(">>>>> Error fetching pending arrivals for stop #{id}: #{e.http_body}")
    raise e
  end
end
