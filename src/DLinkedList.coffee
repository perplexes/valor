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
    callback.call(scope, @value)

  remove: ->
    @prev.next = @next
    @next.prev = @prev
    @next = @prev = null
    @

# Head ----- Tail
class DLinkedList
  constructor: ->
    @head = new DLLNullNode()
    @length = 0

  insert: (value) ->
    @length += 1
    # TODO: object pool
    new DLLNode(@head, value)

  insertNode: (node) ->
    @length += 1
    node.insert(@head)

  remove: (node) ->
    @length -= 1
    node.remove()

  each: (callback, scope) ->
    cur = @head.next
    while cur != @head
      next = cur.next
      cur.visit(callback, scope)
      cur = next
    null

  all: ->
    res = []
    @each (o) ->
      res.push o
    res