require 'roar/decorator'
require 'roar/json/hal'

class TruncatedUserRepresenter < Roar::Decorator
  include Roar::JSON::HAL

  property :id, getter: ->(_) { errors.empty? ? id : nil }
  property :first_name, getter: ->(_) { errors.empty? ? first_name : nil }
  property :last_name, getter: ->(_) { errors.empty? ? last_name : nil }
  property :title, getter: ->(_) { errors.empty? ? title : nil }
  property :organization, getter: ->(_) { errors.empty? ? organization : nil }
  property :errors, getter: ->(_) { errors.empty? ? nil : errors }
end