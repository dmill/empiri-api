require 'roar/decorator'
require 'roar/json/hal'

class ReviewRepresenter < Roar::Decorator
  include Roar::JSON::HAL

  property :id, getter: ->(_) { errors.empty? ? id : nil }
  property :approve, getter: ->(_) { errors.empty? ? approve : nil }
  property :reviewer, embedded: true, extend: TruncatedUserRepresenter, getter: ->(_) { errors.empty? ? reviewer : nil }
  property :errors, getter: ->(_) { errors.empty? ? nil : errors }
end