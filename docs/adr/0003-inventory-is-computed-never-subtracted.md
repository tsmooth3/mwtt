# Inventory is computed from the latest seen, never subtracted

Inventory is remaining trees at a Location this season. It is `seen − collected` from the latest Entry that reported `seen`. It is not a stored counter. A grab-and-go that reports only `collected` does not decrement it; leftover becomes unknown unless the collector says what is still there.

We rejected `remaining -= collected`. A Location can be a whole neighborhood, so two Entries at the same pin are not the same pile. Subtracting sends people to empty curbs. Last year's remaining is compost: a Last-year Hint is presence plus last winter's collected total, never leftover.
