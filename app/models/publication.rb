class Publication < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :reviews, as: :reviewable
  has_many :experiments

  validates :title, presence: true
end