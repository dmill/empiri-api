class Experiment < ActiveRecord::Base
  belongs_to :publication
  has_many :reviews, as: :reviewable


  validates :title, presence: true
  validates :publication, presence: true
end