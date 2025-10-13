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

  def self.at_date(date)
    where(date: date)
  end

  def self.today
    at_date(Date.current)
  end

  def self.yesterday
    at_date(Date.yesterday)
  end

end
