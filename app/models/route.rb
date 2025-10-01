class Route < ApplicationRecord
  belongs_to :line
  has_many :routes_stops, -> { order(:order) }
  has_many :stops, through: :routes_stops
  has_many :arrivals, dependent: :delete_all

  ROUTE_CODE_TO_LINE_IDS = Route.all.includes(:line).map { |r| [ r.code, r.line.line_id ] }.to_h

  def bus_locations
    r = RestClient.get("http://telematics.oasa.gr/api/?act=getBusLocation&p1=#{code}")
    JSON.parse(r.body).presence || []
  end

  def direction
    sanitized_route_desc = description.first(10).gsub(/[^[:word:]]/, "")
    sanitized_line_desc = line.description.first(10).gsub(/[^[:word:]]/, "")
    return "come" if sanitized_route_desc.include?(sanitized_line_desc) || sanitized_route_desc.include?(sanitized_line_desc)
    return "come" unless line.routes.where.not(id: self.id).exists?
    "go"
  end
end
