class Schedule < ApplicationRecord
  DAILY = "daily"
  NORMAL = "normal"

  belongs_to :route

  validates_inclusion_of :type, in: [DAILY, NORMAL]
  self.inheritance_column = nil # to use type column without STI

  def self.daily
    where(type: DAILY)
  end

  def self.normal
    where(type: NORMAL)
  end

end
