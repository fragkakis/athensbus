r = RestClient.get("http://telematics.oasa.gr/api/?act=webGetLines")
lines = JSON.parse(r.body)

line = lines.select{|l| l["LineID"] == "Χ97"}.first

r = RestClient.get("http://telematics.oasa.gr/api/?act=getRoutesForLine&p1=#{line["LineCode"]}")
route = JSON.parse(r.body).first


# r = RestClient.get("http://telematics.oasa.gr/api/?act=webGetRoutesDetailsAndStops&p1=#{route["route_code"]}")
# stops = JSON.parse(r.body)

r = RestClient.get("http://telematics.oasa.gr/api/?act=webGetStops&p1=#{route["route_code"]}")
stop = JSON.parse(r.body).first

r = RestClient.get("http://telematics.oasa.gr/api/?act=getBusLocation&p1=#{route["route_code"]}")
bus_locations = JSON.parse(r.body)

r = RestClient.get("http://telematics.oasa.gr/api/?act=getStopArrivals&p1=#{stop["StopCode"]}")
stop_arrivals = JSON.parse(r.body)

r = RestClient.get("http://telematics.oasa.gr/api/?act=getBusLocation&p1=#{route["route_code"]}")
bus_locations = JSON.parse(r.body)












stop_codes = []
r = RestClient.get("http://telematics.oasa.gr/api/?act=webGetLines")
lines = JSON.parse(r.body)

lines.each do |line|
  puts line["LineCode"]
  r = RestClient.get("http://telematics.oasa.gr/api/?act=getRoutesForLine&p1=#{line["LineCode"]}")
  routes = JSON.parse(r.body)

  routes.each do |route|
    puts "  #{route["route_code"]}"
    r = RestClient.get("http://telematics.oasa.gr/api/?act=webGetStops&p1=#{route["route_code"]}")
    stops = JSON.parse(r.body)

    stop_codes << stops.map { |stop| stop["StopCode"] }
    stop_codes.uniq!
  end
end
#
# threads = []
# Stop.first(200).each do |stop|
#   threads << Thread.new do
#     stop.arrivals
#   end
# end
# threads.each(&:join)
# threads.map(&:value)