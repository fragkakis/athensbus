class Route < ApplicationRecord
  belongs_to :line
  has_many :routes_stops, -> { order(:order) }
  has_many :stops, through: :routes_stops
  has_many :arrivals

  ROUTE_CODE_TO_LINE_IDS = Route.all.includes(:line).map { |r| [ r.code, r.line.line_id ] }.to_h.freeze

  def bus_locations
    r = RestClient.get("http://telematics.oasa.gr/api/?act=getBusLocation&p1=#{code}")
    JSON.parse(r.body).presence || []
  end
end
