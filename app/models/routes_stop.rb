class RoutesStop < ApplicationRecord
  belongs_to :route, dependent: :destroy
  belongs_to :stop
end
