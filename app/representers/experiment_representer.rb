require 'roar/decorator'
require 'roar/json/hal'

class ExperimentRepresenter < Roar::Decorator
  include Roar::JSON::HAL

  property :id, getter: ->(_) { errors.empty? ? id : nil }
  property :publication_id, getter: ->(_) { errors.empty? ? publication_id : nil }
  property :title, getter: ->(_) { errors.empty? ? title : nil }
  property :submitted, getter: ->(_) { errors.empty? ? submitted : nil }
  property :submitted_at, getter: ->(_) { errors.empty? && submitted ? submitted_at.to_s : nil }
  property :results, getter: ->(_) { errors.empty? ? {results: "this is a placeholder for now"} : nil }
  property :discussion, getter: ->(_) { errors.empty? ? "this is a placeholder for now" : nil }
  property :errors, getter: ->(_) { errors.empty? ? nil : errors }

  collection :reviews, embedded: true, extend: ReviewRepresenter, getter: ->(_) { errors.empty? ? reviews : nil }
end
