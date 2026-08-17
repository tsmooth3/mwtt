import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["map", "latitude", "longitude", "locationId", "locationName", "status", "nearby"]
  static values = { nearbyUrl: String }

  connect() {
    if (typeof L === "undefined") return

    const lat = parseFloat(this.latitudeTarget.value)
    const lng = parseFloat(this.longitudeTarget.value)
    const start = Number.isFinite(lat) && Number.isFinite(lng) ? [lat, lng] : [39.607, -76.662]

    this.map = L.map(this.mapTarget).setView(start, Number.isFinite(lat) ? 14 : 11)
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap"
    }).addTo(this.map)

    if (Number.isFinite(lat) && Number.isFinite(lng)) {
      this.placeMarker(lat, lng)
    }

    this.map.on("click", (event) => {
      this.setCoordinates(event.latlng.lat, event.latlng.lng, { clearExisting: true })
      this.loadNearby(event.latlng.lat, event.latlng.lng)
    })
  }

  disconnect() {
    if (this.map) this.map.remove()
  }

  useGps() {
    if (!navigator.geolocation) {
      this.statusTarget.textContent = "This browser cannot share a location."
      return
    }

    this.statusTarget.textContent = "Asking for location…"
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const lat = position.coords.latitude
        const lng = position.coords.longitude
        this.map.setView([lat, lng], 15)
        this.setCoordinates(lat, lng, { clearExisting: true })
        this.loadNearby(lat, lng)
      },
      () => {
        this.statusTarget.textContent = "Location permission denied. Drop a pin instead."
      }
    )
  }

  clear() {
    this.latitudeTarget.value = ""
    this.longitudeTarget.value = ""
    this.locationIdTarget.value = ""
    if (this.hasLocationNameTarget) this.locationNameTarget.value = ""
    if (this.marker) {
      this.map.removeLayer(this.marker)
      this.marker = null
    }
    this.nearbyTarget.innerHTML = ""
    this.statusTarget.textContent = "Tap the map to drop a pin, or leave it blank."
  }

  chooseExisting(event) {
    const button = event.currentTarget
    this.locationIdTarget.value = button.dataset.id
    this.latitudeTarget.value = button.dataset.lat
    this.longitudeTarget.value = button.dataset.lng
    if (this.hasLocationNameTarget) this.locationNameTarget.value = button.dataset.name
    this.placeMarker(parseFloat(button.dataset.lat), parseFloat(button.dataset.lng))
    this.statusTarget.textContent = `Using ${button.dataset.name}.`
  }

  setCoordinates(lat, lng, { clearExisting } = {}) {
    this.latitudeTarget.value = lat.toFixed(6)
    this.longitudeTarget.value = lng.toFixed(6)
    if (clearExisting) this.locationIdTarget.value = ""
    this.placeMarker(lat, lng)
    this.statusTarget.textContent = this.locationIdTarget.value ? "Using an existing pin." : "New pin ready. Save to keep it."
  }

  placeMarker(lat, lng) {
    if (this.marker) this.map.removeLayer(this.marker)
    this.marker = L.marker([lat, lng]).addTo(this.map)
  }

  async loadNearby(lat, lng) {
    if (!this.nearbyUrlValue) return

    const url = new URL(this.nearbyUrlValue, window.location.origin)
    url.searchParams.set("lat", lat)
    url.searchParams.set("lng", lng)

    const response = await fetch(url, { headers: { Accept: "application/json" } })
    if (!response.ok) return
    const locations = await response.json()
    this.renderNearby(locations)
  }

  renderNearby(locations) {
    if (!locations.length) {
      this.nearbyTarget.innerHTML = ""
      return
    }

    this.nearbyTarget.innerHTML = locations.map((location) => `
      <button type="button"
              class="w-full text-left px-3 py-2 rounded-lg bg-[#152a48] border border-[#1e3a5f] text-xs text-[#f4efe4] hover:border-[#c4a35a]"
              data-action="pin-picker#chooseExisting"
              data-id="${location.id}"
              data-lat="${location.latitude}"
              data-lng="${location.longitude}"
              data-name="${location.name}">
        Use ${location.name}
      </button>
    `).join("")
  }
}
