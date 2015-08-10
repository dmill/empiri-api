require 'roar/decorator'
require 'roar/json/hal'

class TruncatedExperimentRepresenter < Roar::Decorator
  include Roar::JSON::HAL

  property :id, getter: ->(_) { errors.empty? ? id : nil }
  property :title, getter: ->(_) { errors.empty? ? title : nil }
  property :errors, getter: ->(_) { errors.empty? ? nil : errors }
end