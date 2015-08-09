require 'roar/decorator'
require 'roar/json/hal'

class TruncatedThreadRepresenter < Roar::Decorator
  include Roar::JSON::HAL

  property :id, getter: ->(_) { errors.empty? ? id : nil }
  property :title, getter: ->(_) { errors.empty? ? title : nil }
  property :errors, getter: ->(_) { errors.empty? ? nil : errors }
  property :closed, getter: ->(_) { errors.empty? ? closed : nil }
  property :closed_at, getter: ->(_) { errors.empty? && closed ? closed_at.to_s : nil }

  collection :authors, embedded: true, extend: TruncatedUserRepresenter, getter: ->(_) { errors.empty? ? users : nil }
end