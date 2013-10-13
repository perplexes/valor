class DLLNullNode
  constructor: -> @next = @prev = @
  visit: (callback, scope) -> @
  remove: -> @

class DLLNode
  # Insert after prev
  constructor: (prev, value) ->
    @value = value
    @insert(prev)

  insert: (prev) ->
    @prev = prev
    @next = prev.next
    @next.prev = prev.next = @

  visit: (callback, scope) ->
    next = @next # Might modify
    callback.call(scope, @value)
    next.visit(callback, scope)

  remove: ->
    @prev.next = @next
    @next.prev = @prev
    @next = @prev = null
    @

# Head ----- Tail
class DLinkedList
  constructor: ->
    @head = new DLLNullNode()

  insert: (value) ->
    # TODO: object pool
    new DLLNode(@head, value)

  insertNode: (node) ->
    node.insert(@head)

  remove: (node) ->
    node.remove()

  each: (callback, scope) ->
    @head.next.visit(callback, scope)