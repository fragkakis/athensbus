def athens?
  ENV.fetch("CITY_NAME", "athens") == "athens"
end

def thessaloniki?
  ENV.fetch("CITY_NAME", "athens") == "thessaloniki"
end

CITY_NAME = athens? ? "Αθήνα" : "Θεσσαλονίκη"
AUTHORITY_NAME = athens? ? "ΟΑΣΑ" : "ΟΑΣΘ"
TELEMATICS_BASE_URL = athens? ? "http://telematics.oasa.gr" : "http://telematics.oasth.gr"
APP_NAME = athens? ? "AthensBus.info" : "ThessBus.info"
APP_NAME_NO_DOMAIN = athens? ? "Athens Bus" : "Thess Bus"
