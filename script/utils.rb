r = RestClient.get("http://telematics.oasa.gr/api/?act=webGetLines")
lines = JSON.parse(r.body)

lines.each do |line|
  l = Line.create(code: line["LineCode"], line_id: line["LineID"], description: line["LineDescr"], description_en: line["LineDescrEng"])

  r = RestClient.get("http://telematics.oasa.gr/api/?act=getRoutesForLine&p1=#{line["LineCode"]}")
  routes = JSON.parse(r.body)
  routes.each do |route|
    l.routes.create!(code: route["route_code"], route_id: route["route_id"],
                    description: route["route_descr"], description_en: route["route_descr_eng"],
                    active: route["route_active" == "1"])
  end
end



# r = RestClient.get("http://telematics.oasa.gr/api/?act=webGetRoutesDetailsAndStops&p1=#{route["route_code"]}")
# stopsJSON.parse(r.body).first



r = RestClient.get("http://telematics.oasa.gr/api/?act=webGetStops&p1=#{route["route_code"]}")
stops = JSON.parse(r.body)

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

threads = []
Stop.first(200).each do |stop|
  threads << Thread.new do
    stop.arrivals
  end
end
threads.each(&:join)
threads.map(&:value)