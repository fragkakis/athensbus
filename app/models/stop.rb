class Stop < ApplicationRecord
  has_many :routes_stops
  has_many :routes, through: :routes_stops
  has_many :arrivals

  PENDING_ARRIVALS_URL = athens? ?
                           "#{TELEMATICS_BASE_URL}/api/?act=getStopArrivals&p1=%{code}" :
                           "#{TELEMATICS_BASE_URL}/el/api/getStopArrivals/%{code}/?a=1"

  def pending_arrivals
    r = RestClient::Request.execute(method: :get,
                                    url: PENDING_ARRIVALS_URL % { code: code },
                                    timeout: 5)
    arrivals = JSON.parse(r.body)
    return [] if arrivals.blank?

    arrivals.map do |arrival|
      { "line_code" => Route::ROUTE_CODE_TO_LINE_IDS[arrival["route_code"]] }.merge(arrival)
    end
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error(">>>>> Error fetching pending arrivals for stop #{id}: #{e.http_body}")
    raise e
  end

  def get_routes
    r = RestClient.get("#{TELEMATICS_BASE_URL}/api/?act=webGetRoutes&p1=#{code}")
    JSON.parse(r.body)
  end
end
