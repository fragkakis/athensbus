class Route < ApplicationRecord
  belongs_to :line
  has_many :routes_stops, -> { order(:order) }
  has_many :stops, through: :routes_stops
  has_many :arrivals, dependent: :delete_all
  has_many :schedules, dependent: :delete_all
  has_many :route_daily_reports, dependent: :delete_all

  ROUTE_CODE_TO_LINE_IDS = Route.all.includes(:line).map { |r| [ r.code, r.line.line_id ] }.to_h
  COME = "come"
  GO = "go"

  def bus_locations
    r = RestClient.get("http://telematics.oasa.gr/api/?act=getBusLocation&p1=#{code}")
    JSON.parse(r.body).presence || []
  end

  def come?
    auto_calculated_direction == COME
  end

  def go?
    auto_calculated_direction == GO
  end

  private

  def auto_calculated_direction
    @auto_calculated_direction ||= calculate_auto_calculated_direction
  end

  def calculate_auto_calculated_direction
    return GO unless line.routes.where.not(id: self.id).exists?
    return GO if line.description.include?("ΚΥΚΛΙΚΗ")
    sanitized_route_desc = description.gsub(/[^[:word:]]/, "").first(10)
    sanitized_line_desc = line.description.gsub(/[^[:word:]]/, "").first(10)
    return GO if sanitized_route_desc.include?(sanitized_line_desc) || sanitized_route_desc.include?(sanitized_line_desc)
    COME
  end
end
