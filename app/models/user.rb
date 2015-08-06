class User < ActiveRecord::Base
  has_and_belongs_to_many :publications
  has_many :reviews

  validates_presence_of :first_name, :last_name, :organization, :title
end