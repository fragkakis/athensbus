class Arrival < ApplicationRecord
  belongs_to :route
  belongs_to :stop
  belongs_to :vehicle
end
