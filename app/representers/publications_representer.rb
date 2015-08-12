require 'roar/decorator'
require 'roar/json/hal'

class PublicationsRepresenter < Roar::Decorator
  include Roar::JSON::HAL

  collection :publications, extend: TruncatedPublicationRepresenter, getter: ->(_) { self || [] }
end