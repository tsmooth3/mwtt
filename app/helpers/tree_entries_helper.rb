module TreeEntriesHelper
  def entry_summary(entry, filter: nil)
    if scouting_inventory?(entry, filter)
      "#{entry.remaining} remaining"
    elsif entry.seen.present?
      "#{entry.collected} collected · #{entry.seen} seen"
    else
      "#{entry.collected} collected"
    end
  end

  def entry_kind_label(entry, filter: nil)
    return "Inventory" if scouting_inventory?(entry, filter)
    return "Empty check" if entry.empty_check?
    return "Sighting" if entry.sighting?
    "Collection"
  end

  def entry_primary_count(entry, filter: nil)
    scouting_inventory?(entry, filter) ? entry.remaining : entry.collected
  end

  def entry_primary_unit(entry, filter: nil)
    scouting_inventory?(entry, filter) ? "remaining" : "collected"
  end

  def scouting_inventory?(entry, filter)
    filter == "scouting" && entry.leftover?
  end
end
