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

  visit: (callback) ->
    callback(@value)

  remove: ->
    @prev.next = @next
    @next.prev = @prev
    @prev = @next = null
    # We keep @next around in case we're in the middle of iterating using it
    # TODO: Track down why the iterator would stop working in this case.
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
    @nodes[hash].remove()
    delete this.nodes[hash]

  each: (callback) ->
    cur = @head.next
    was_null = false
    while cur != @head
      next = cur.next
      was_null = next == null
      cur.visit(callback)
      debugger if next == null
      cur = next
    null

  all: ->
    res = []
    @each (o) ->
      res.push o
    res

  count: ->
    count = 0
    @each -> count += 1
    count