r = RestClient.get("#{TELEMATICS_BASE_URL}/api/?act=webGetLines", origin: TELEMATICS_BASE_URL)
lines = JSON.parse(r.body)

line = lines.select { |l| l["LineID"] == "Χ97" }.first

r = RestClient.get("#{TELEMATICS_BASE_URL}/api/?act=getRoutesForLine&p1=#{line["LineCode"]}", origin: TELEMATICS_BASE_URL)
route = JSON.parse(r.body).first


# r = RestClient.get("#{TELEMATICS_BASE_URL}/api/?act=webGetRoutesDetailsAndStops&p1=#{route["route_code"]}", origin: TELEMATICS_BASE_URL)
# stops = JSON.parse(r.body)

r = RestClient.get("#{TELEMATICS_BASE_URL}/api/?act=webGetStops&p1=#{route["route_code"]}", origin: TELEMATICS_BASE_URL)
stop = JSON.parse(r.body).first

r = RestClient.get("#{TELEMATICS_BASE_URL}/api/?act=getBusLocation&p1=#{route["route_code"]}", origin: TELEMATICS_BASE_URL)
bus_locations = JSON.parse(r.body)

r = RestClient.get("#{TELEMATICS_BASE_URL}/api/?act=getStopArrivals&p1=#{stop["StopCode"]}", origin: TELEMATICS_BASE_URL)
stop_arrivals = JSON.parse(r.body)

r = RestClient.get("#{TELEMATICS_BASE_URL}/api/?act=getBusLocation&p1=#{route["route_code"]}", origin: TELEMATICS_BASE_URL)
bus_locations = JSON.parse(r.body)












stop_codes = []
r = RestClient.get("#{TELEMATICS_BASE_URL}/api/?act=webGetLines", origin: TELEMATICS_BASE_URL)
lines = JSON.parse(r.body)

lines.each do |line|
  puts line["LineCode"]
  r = RestClient.get("#{TELEMATICS_BASE_URL}/api/?act=getRoutesForLine&p1=#{line["LineCode"]}", origin: TELEMATICS_BASE_URL)
  routes = JSON.parse(r.body)

  routes.each do |route|
    puts "  #{route["route_code"]}"
    r = RestClient.get("#{TELEMATICS_BASE_URL}/api/?act=webGetStops&p1=#{route["route_code"]}", origin: TELEMATICS_BASE_URL)
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
