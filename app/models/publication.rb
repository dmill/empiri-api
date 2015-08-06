class Publication < ActiveRecord::Base
  has_and_belongs_to_many :authors, class_name: "User", foreign_key: :user_id
  has_many :reviews, as: :reviewable
  has_many :experiments

  validates :title, presence: true
end