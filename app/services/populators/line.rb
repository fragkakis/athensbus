module Populators
  class Line
    def self.populate_all
      r = RestClient.get("http://telematics.oasa.gr/api/?act=webGetLines")
      lines = JSON.parse(r.body)

      lines.each do |line|
        populate(line)
      end
    end

    def self.populate(line_payload)
      Rails.logger.info("Creating line #{line_payload["LineCode"]}")
      l = ::Line.create!(code: line_payload["LineCode"], line_id: line_payload["LineID"])
      l.update!(description: line_payload["LineDescr"], description_en: line_payload["LineDescrEng"])

      ::Populators::Route.populate(l)
    end
  end
end
