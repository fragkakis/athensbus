module Populators
  class Route
    def self.populate(line)
      r = RestClient.get("http://telematics.oasa.gr/api/?act=getRoutesForLine&p1=#{line.code}")
      routes = JSON.parse(r.body)
      routes.each do |route|
        Rails.logger.info("\tCreating route #{route["route_code"]}")
        rt = line.routes.find_or_create_by!(code: route["route_code"], route_id: route["route_id"])
        rt.update!(description: route["route_descr"], description_en: route["route_descr_eng"], active: route["route_active"] == "1")

        r = RestClient.get("http://telematics.oasa.gr/api/?act=webGetStops&p1=#{route["route_code"]}")
        stops = JSON.parse(r.body)

        stops.each do |stop|
          Rails.logger.info("\t\tCreating stop #{stop["StopCode"]}")
          st = Stop.find_or_create_by!(code: stop["StopCode"], stop_id: stop["StopID"])
          st.update!(description: stop["StopDescr"], description_en: stop["StopDescrEng"],
                                       street: stop["StopStreet"], street_en: stop["StopStreetEng"],
                                       heading: stop["StopHeading"], lat: stop["StopLat"], lng: stop["StopLng"],
                                       stop_type: stop["StopType"], amea: stop["StopAmea"]=="1")
          RoutesStop.create!(route: rt, stop: st, order: stop["RouteStopOrder"])
        end
      end
    end
  end
end
