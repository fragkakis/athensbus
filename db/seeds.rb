# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
r = RestClient.get("http://telematics.oasa.gr/api/?act=webGetLines")
lines = JSON.parse(r.body)

lines.each do |line|
  puts "Creating line #{line["LineCode"]}"
  l = Line.create(code: line["LineCode"], line_id: line["LineID"], description: line["LineDescr"], description_en: line["LineDescrEng"])

  r = RestClient.get("http://telematics.oasa.gr/api/?act=getRoutesForLine&p1=#{line["LineCode"]}")
  routes = JSON.parse(r.body)
  routes.each do |route|
    puts "  Creating route #{route["route_code"]}"
    rt = l.routes.create!(code: route["route_code"], route_id: route["route_id"],
                     description: route["route_descr"], description_en: route["route_descr_eng"],
                     active: route["route_active" == "1"])

    r = RestClient.get("http://telematics.oasa.gr/api/?act=webGetStops&p1=#{route["route_code"]}")
    stops = JSON.parse(r.body)

    stops.each do |stop|
      puts "    Creating stop #{stop["StopCode"]}"
      st = Stop.find_or_create_by!(code: stop["StopCode"], stop_id: stop["StopID"],
                        description: stop["StopDescr"], description_en: stop["StopDescrEng"],
                        street: stop["StopStreet"], street_en: stop["StopStreetEng"],
                        heading: stop["StopHeading"], lat: stop["StopLat"], lng: stop["StopLng"],
                        stop_type: stop["StopType"], amea: stop["StopAmea"]=="1")
      RoutesStop.create!(route: rt, stop: st, order: stop["RouteStopOrder"])
    end
  end
end