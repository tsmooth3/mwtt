import { Controller } from "@hotwired/stimulus"

const COLORS = {
  inventory: "#22c55e",
  unknown: "#e0c57a",
  cleared: "#4ea1ff",
  empty: "#9eb4d4",
  last_year: "#7a6a4a"
}

export default class extends Controller {
  static targets = ["canvas", "popup", "filters"]
  static values = {
    pins: Array,
    recap: Boolean,
    interactive: { type: Boolean, default: false },
    mapPath: String,
    newEntryPath: String,
    hidePathTemplate: String
  }

  connect() {
    if (typeof L === "undefined") return

    this.activeStates = new Set(["inventory", "unknown", "cleared", "empty", "last_year"])
    this.map = L.map(this.canvasTarget, { scrollWheelZoom: this.interactiveValue })
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap"
    }).addTo(this.map)

    this.drawPins()
    this.fit()

    if (this.interactiveValue) {
      this.map.on("click", (event) => this.openNewPin(event.latlng))
    }
  }

  disconnect() {
    if (this.map) this.map.remove()
  }

  toggleState(event) {
    const state = event.currentTarget.dataset.state
    if (this.activeStates.has(state)) {
      this.activeStates.delete(state)
    } else {
      this.activeStates.add(state)
    }
    event.currentTarget.classList.toggle("opacity-40")
    this.drawPins()
  }

  drawPins() {
    if (this.layer) this.map.removeLayer(this.layer)

    const clustered = this.interactiveValue && typeof L.markerClusterGroup === "function"
    this.layer = clustered
      ? L.markerClusterGroup({
          showCoverageOnHover: false,
          maxClusterRadius: 50,
          iconCreateFunction: (cluster) => this.clusterIcon(cluster)
        })
      : L.layerGroup()

    this.visiblePins().forEach((pin) => {
      const marker = L.circleMarker([pin.latitude, pin.longitude], {
        radius: pin.state === "last_year" ? 7 : 9,
        color: COLORS[pin.state] || "#c4a35a",
        fillColor: COLORS[pin.state] || "#c4a35a",
        fillOpacity: pin.state === "last_year" ? 0.35 : 0.9,
        weight: 2
      })
      marker.pin = pin
      marker.bindTooltip(this.pinLabel(pin), { permanent: !clustered, direction: "top", offset: [0, -8], className: "hunt-pin-label" })
      marker.on("click", (event) => {
        L.DomEvent.stopPropagation(event)
        this.showPopup(pin)
      })
      this.layer.addLayer(marker)
    })

    this.map.addLayer(this.layer)
  }

  clusterIcon(cluster) {
    const pins = cluster.getAllChildMarkers().map((marker) => marker.pin).filter(Boolean)
    const label = this.clusterLabel(pins)
    return L.divIcon({
      html: `<div class="hunt-cluster">${label}</div>`,
      className: "",
      iconSize: [72, 36]
    })
  }

  clusterLabel(pins) {
    const operational = pins.filter((pin) => pin.state !== "last_year")
    const collected = operational.reduce((sum, pin) => sum + (pin.collected || 0), 0)
    if (this.recapValue) return `${collected}`

    const known = operational.filter((pin) => pin.remaining != null)
    const leftover = known.reduce((sum, pin) => sum + pin.remaining, 0)
    const unknown = operational.some((pin) => pin.remaining == null && pin.state !== "empty")
    let remaining = leftover.toString()
    if (unknown && leftover > 0) remaining = `${leftover}+?`
    if (unknown && leftover === 0) remaining = "?"
    return `${collected} ↑<br>${remaining} left`
  }

  visiblePins() {
    return this.pinsValue.filter((pin) => this.activeStates.has(pin.state))
  }

  pinLabel(pin) {
    if (pin.state === "last_year") return pin.previous_collected ? `${pin.previous_collected}` : "·"
    if (this.recapValue) return `${pin.collected}`
    const remaining = pin.remaining == null ? "?" : pin.remaining
    return `${pin.collected} / ${remaining}`
  }

  fit() {
    const pins = this.visiblePins()
    if (pins.length) {
      const bounds = L.latLngBounds(pins.map((pin) => [pin.latitude, pin.longitude]))
      this.map.fitBounds(bounds, { padding: [30, 30], maxZoom: 13 })
    } else {
      this.map.setView([39.607, -76.662], 11)
    }
  }

  showPopup(pin) {
    if (!this.hasPopupTarget) {
      if (this.mapPathValue) window.location.href = this.mapPathValue
      return
    }

    const remaining = pin.remaining == null ? "unknown" : pin.remaining
    const lastYear = pin.previous_collected != null
      ? `<p class="text-[11px] text-[#c4a35a] mt-2">Last year: ${pin.previous_collected} collected${pin.previous_last_visited_on ? ` · ${pin.previous_last_visited_on}` : ""}</p>`
      : ""
    const leftoverPrompt = pin.state === "unknown"
      ? `<p class="text-[11px] text-[#e0c57a] mt-2">What’s left? Log a visit and report seen.</p>`
      : ""
    const visits = (pin.visits || []).map((visit) => {
      const seen = visit.seen == null ? "seen ?" : `${visit.seen} seen`
      return `<li class="text-[11px] text-[#9eb4d4]">${visit.date} · ${visit.visitor} · ${visit.collected} collected · ${seen}</li>`
    }).join("")
    const history = visits
      ? `<details class="mt-3"><summary class="text-[11px] text-[#c4a35a] cursor-pointer">All visits</summary><ul class="mt-2 space-y-1">${visits}</ul></details>`
      : ""
    const hideLink = this.hidePathTemplateValue
      ? `<form action="${this.hidePathTemplateValue.replace("__ID__", pin.id)}" method="post" class="inline">${this.csrfField()}<input type="hidden" name="_method" value="patch"><button type="submit" class="px-3 py-1.5 border border-[#1e3a5f] text-[#c9bda4] rounded-lg text-xs">Hide pin</button></form>`
      : ""

    this.popupTarget.innerHTML = `
      <div class="flex items-start justify-between gap-3">
        <div>
          <p class="text-[11px] uppercase tracking-wider text-[#c4a35a] font-bold">${pin.state.replace("_", " ")}</p>
          <h3 class="text-lg font-bold text-[#f4efe4]">${pin.name}</h3>
        </div>
        <button type="button" data-action="hunt-map#closePopup" class="text-[#9eb4d4] text-sm">✕</button>
      </div>
      <p class="text-sm text-[#9eb4d4] mt-2">${pin.collected} collected · ${remaining} remaining</p>
      <p class="text-xs text-[#9eb4d4] mt-1">Last visit ${pin.last_visited_on || "—"} · ${pin.last_visitor || ""}</p>
      ${leftoverPrompt}
      ${lastYear}
      ${history}
      <div class="flex flex-wrap gap-2 mt-4">
        <a href="${this.newEntryPathValue}?location_id=${pin.id}" class="px-3 py-1.5 bg-[#16a34a] text-white rounded-lg text-xs font-bold">Log a visit here</a>
        ${hideLink}
      </div>
    `
    this.popupTarget.classList.remove("hidden")
  }

  csrfField() {
    const token = document.querySelector("meta[name='csrf-token']")
    if (!token) return ""
    return `<input type="hidden" name="authenticity_token" value="${token.content}">`
  }

  closePopup() {
    if (this.hasPopupTarget) this.popupTarget.classList.add("hidden")
  }

  openNewPin(latlng) {
    const url = new URL(this.newEntryPathValue, window.location.origin)
    url.searchParams.set("lat", latlng.lat.toFixed(6))
    url.searchParams.set("lng", latlng.lng.toFixed(6))
    window.location.href = url.toString()
  }
}
