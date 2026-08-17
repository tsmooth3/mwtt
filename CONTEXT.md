# Mid-Winter Tree Tracker

Families collect discarded Christmas trees for a shared bonfire. The app tracks how many have been hauled toward a season goal, and where it is still worth looking.

## People

**Family**:
A named group that collects together and shares credit toward the season goal.
_Avoid_: Team, household, group

**Family Admin**:
A member who can set the season goal and manage that family's Entries and Locations.
_Avoid_: Owner

## Season

**Season**:
The winter after a Christmas, labeled by that Christmas's year. 4 January 2027 is season 2026. Dates inside 1 December–15 February belong to that hunt; dates outside it belong to the upcoming Christmas so off-season logging still works.
_Avoid_: Calendar year, year

**Season Goal**:
The number of collected trees, across all families, that the bonfire is aiming for this season. Defaults to the age of the USA that winter (season 2025 → 250). An admin can override it.
_Avoid_: Quota

## Field report

**Entry**:
A dated field report of what was seen and what was collected, by a user, at an optional Location. Collected trees are credited to a family; a scout or empty check needs no family.
_Avoid_: Visit, log, Tree Entry, sighting (as the record itself)

**Collected**:
Trees actually taken during an Entry. These count toward the season goal and family totals.
_Avoid_: Picked up, hauled

**Seen**:
Trees observed at a Location during an Entry, including zero. What was there, not what was taken.

**Empty Check**:
An Entry with seen 0 and collected 0: we looked, nothing was there, on that date.
_Avoid_: Negative report, cleared (cleared means trees were taken and none remain)

## Place

**Location**:
A reusable place — a driveway, a curb, or a neighborhood centroid — identified by coordinates and an optional name.
_Avoid_: Pin, marker, market, spot, place

**Inventory**:
The trees still believed to be at a Location this season: remaining from the latest Entry that reported seen. Unknown when no such report exists. Does not survive the season.
_Avoid_: Stock, leftover (as the name of the concept)

**Last-year Hint**:
A Location that had activity last season, used only as a signal that it may be worth looking again. Not inventory.
_Avoid_: Previous-season inventory, leftover
