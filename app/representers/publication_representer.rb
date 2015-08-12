require 'roar/decorator'
require 'roar/json/hal'

class PublicationRepresenter < Roar::Decorator
  include Roar::JSON::HAL

  property :id, getter: ->(_) { errors.empty? ? id : nil }
  property :title, getter: ->(_) { errors.empty? ? title : nil }
  property :errors, getter: ->(_) { errors.empty? ? nil : errors }
  property :closed, getter: ->(_) { errors.empty? ? closed : nil }
  property :closed_at, getter: ->(_) { errors.empty? && closed ? closed_at.to_s : nil }

  collection :authors, embedded: true, extend: TruncatedUserRepresenter, getter: ->(_) { errors.empty? ? users : nil }
  collection :experiments, embedded: true, extend: TruncatedExperimentRepresenter,  getter: ->(_) { errors.empty? ? experiments : nil }
  collection :reviews, embedded: true, extend: ReviewRepresenter, getter: ->(_) { errors.empty? ? reviews : nil }
end