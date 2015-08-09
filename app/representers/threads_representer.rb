require 'roar/decorator'
require 'roar/json/hal'

class ThreadsRepresenter < Roar::Decorator
  include Roar::JSON::HAL

  collection :threads, extend: TruncatedThreadRepresenter, getter: ->(_) { self || [] }
end