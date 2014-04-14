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
    @nodes = {}

  insert: (value, hash) ->
    @length += 1
    # TODO: object pool
    node = new DLLNode(@head, value)
    @nodes[hash] = node

  insertNode: (node) ->
    @length += 1
    node.insert(@head)

  remove: (hash) ->
    @length -= 1
    nodes[hash].remove()
    delete nodes[hash]

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