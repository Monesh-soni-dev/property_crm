import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "plotLength", "plotWidth", "plotArea", "maxArea",
    "constructionArea", "floors", "city", "qualityTier",
    "preview"
  ]

  static values = {
    url: { type: String, default: "/construction_estimates/calculate_costs" },
    debounce: { type: Number, default: 500 }
  }

  connect() {
    this._timeout = null
    this.updatePlotArea()
  }

  calculate() {
    this.updatePlotArea()
    this.debouncedFetch()
  }

  updatePlotArea() {
    const length = parseFloat(this.plotLengthTarget.value) || 0
    const width = parseFloat(this.plotWidthTarget.value) || 0
    const area = length * width

    if (this.hasPlotAreaTarget) {
      this.plotAreaTarget.textContent = area.toLocaleString("en-IN")
    }

    // Update FAR-based max area
    const city = this.hasCityTarget ? this.cityTarget.value : ""
    const far = this.getFAR(city)
    const maxArea = area * far

    if (this.hasMaxAreaTarget) {
      this.maxAreaTarget.textContent = maxArea > 0 ? maxArea.toLocaleString("en-IN") : "-"
    }

    // Update plot visualizer if on page
    const visualizer = document.querySelector('[data-controller="plot-visualizer"]')
    if (visualizer) {
      visualizer.dataset.plotVisualizerLengthValue = length
      visualizer.dataset.plotVisualizerWidthValue = width
      const constArea = parseFloat(this.hasConstructionAreaTarget ? this.constructionAreaTarget.value : 0) || 0
      visualizer.dataset.plotVisualizerConstructionAreaValue = constArea
    }
  }

  getFAR(city) {
    const farMap = {
      "Bangalore": 2.5, "Mumbai": 3.0, "Delhi": 3.5,
      "Chennai": 2.5, "Hyderabad": 2.5, "Pune": 2.0,
      "Kolkata": 2.5, "Ahmedabad": 2.0
    }
    return farMap[city] || 2.0
  }

  debouncedFetch() {
    clearTimeout(this._timeout)
    this._timeout = setTimeout(() => this.fetchCosts(), this.debounceValue)
  }

  async fetchCosts() {
    const length = parseFloat(this.plotLengthTarget.value) || 0
    const width = parseFloat(this.plotWidthTarget.value) || 0
    const constArea = parseFloat(this.hasConstructionAreaTarget ? this.constructionAreaTarget.value : 0) || 0
    const floors = this.hasFloorsTarget ? parseInt(this.floorsTarget.value) || 1 : 1
    const city = this.hasCityTarget ? this.cityTarget.value : ""

    // Find selected quality tier
    let tier = "standard"
    if (this.hasQualityTierTarget) {
      const checkedRadio = this.qualityTierTargets.find(r => r.checked)
      if (checkedRadio) tier = checkedRadio.value
    }

    if (length <= 0 || width <= 0 || constArea <= 0 || !city) return

    // Show loading state
    if (this.hasPreviewTarget) {
      this.previewTarget.innerHTML = `
        <div class="bg-white rounded-2xl border border-slate-200 p-6">
          <h3 class="text-lg font-semibold text-slate-900 mb-3">Calculating...</h3>
          <div class="animate-pulse space-y-3">
            <div class="h-4 bg-blue-100 rounded w-3/4"></div>
            <div class="h-8 bg-blue-100 rounded w-1/2"></div>
            <div class="h-4 bg-blue-100 rounded w-full"></div>
          </div>
        </div>`
    }

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
      const formData = new FormData()
      formData.append("construction_estimate[plot_length]", length)
      formData.append("construction_estimate[plot_width]", width)
      formData.append("construction_estimate[construction_area]", constArea)
      formData.append("construction_estimate[number_of_floors]", floors)
      formData.append("construction_estimate[city]", city)
      formData.append("construction_estimate[quality_tier]", tier)

      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "text/vnd.turbo-stream.html"
        },
        body: formData
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Cost calculation error:", error)
    }
  }
}
