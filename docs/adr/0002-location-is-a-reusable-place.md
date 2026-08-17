# Location is a reusable place, not GPS on an Entry

The map's job is "where do we drive, and have we already been there." That only works if a place exists independently of this year's Entries. A Location is a first-class reusable pin (driveway or neighborhood centroid). An Entry may attach to one; a collection without a pin still counts toward the goal.

We rejected storing raw coordinates on each Entry and inferring "same place" by proximity. Two visits to the same curb never quite match, and neighborhood-scale pins make auto-snap a silent lie. Nearby existing Locations are offered; the user chooses. No silent merge.
