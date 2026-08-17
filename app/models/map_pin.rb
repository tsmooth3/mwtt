class MapPin
  STATES = %w[inventory unknown cleared empty last_year].freeze

  def self.for_season(season, include_previous: false, recap: false)
    previous = season.previous
    locations = Location.visible.includes(:tree_entries).to_a

    locations.filter_map do |location|
      build(location, season, previous, include_previous: include_previous, recap: recap)
    end
  end

  def self.build(location, season, previous, include_previous:, recap:)
    this_entries = location.season_entries(season)
    previous_entries = location.season_entries(previous)
    return if this_entries.empty? && previous_entries.empty?
    return if this_entries.empty? && !include_previous

    if this_entries.empty?
      last_previous = previous_entries.first
      return {
        id: location.id,
        name: location.display_name,
        latitude: location.latitude.to_f,
        longitude: location.longitude.to_f,
        state: "last_year",
        collected: 0,
        remaining: nil,
        previous_collected: previous_entries.sum(&:collected),
        previous_last_visited_on: last_previous&.entry_date,
        last_visited_on: last_previous&.entry_date,
        last_visitor: last_previous && visitor_label(last_previous),
        recap: recap
      }
    end

    last_entry = this_entries.first
    leftover = recap ? nil : last_entry.remaining
    collected = this_entries.sum(&:collected)
    state = recap ? recap_state(leftover, collected, last_entry) : location.operational_state(season).to_s

    {
      id: location.id,
      name: location.display_name,
      latitude: location.latitude.to_f,
      longitude: location.longitude.to_f,
      state: state,
      collected: collected,
      remaining: leftover,
      previous_collected: include_previous ? previous_entries.sum(&:collected) : nil,
      previous_last_visited_on: include_previous ? previous_entries.first&.entry_date : nil,
      last_visited_on: last_entry.entry_date,
      last_visitor: visitor_label(last_entry),
      last_seen: last_entry.seen,
      last_collected: last_entry.collected,
      visits: this_entries.first(8).map { |entry| visit_payload(entry) },
      recap: recap
    }
  end

  def self.visit_payload(entry)
    {
      date: entry.entry_date,
      visitor: visitor_label(entry),
      seen: entry.seen,
      collected: entry.collected
    }
  end

  def self.recap_state(_leftover, collected, last_entry)
    if collected.positive?
      "cleared"
    elsif last_entry.empty_check?
      "empty"
    else
      "unknown"
    end
  end

  def self.visitor_label(entry)
    parts = []
    parts << entry.family.name if entry.family
    parts << entry.user.email
    parts.join(" · ")
  end

  def self.cluster_label(pins, recap: false)
    operational = pins.reject { |pin| pin[:state] == "last_year" }
    collected = operational.sum { |pin| pin[:collected].to_i }
    return collected.to_s if recap

    known = operational.select { |pin| !pin[:remaining].nil? }
    leftover = known.sum { |pin| pin[:remaining].to_i }
    unknown = operational.any? { |pin| pin[:remaining].nil? && pin[:state] != "empty" }

    remaining = if unknown && leftover.positive?
      "#{leftover}+?"
    elsif unknown && leftover.zero?
      "?"
    else
      leftover.to_s
    end

    "#{collected} ↑ · #{remaining} left"
  end
end
