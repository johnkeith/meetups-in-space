class Meetup < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :location, presence: true

  has_many :users_at_meetups
  has_many :users, through: :users_at_meetups
end
