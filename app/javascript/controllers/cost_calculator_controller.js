import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input", "preview", "plotArea", "constructionArea", "buildableArea", "costPerSqft", "errors", "breakdownContainer", "qualityOption", "statusOption"]
  static values = { url: String }

  connect() {
    this.timeout = null
    this.syncSelectionStates()
    this.calculate()
  }

  calculate() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.performCalculation(), 250)
  }

  async performCalculation() {
    const params = new URLSearchParams(new FormData(this.formTarget))
    this.previewTarget.classList.add("opacity-70")
    this.hideErrors()

    try {
      const response = await fetch(`${this.urlValue}?${params.toString()}`, {
        headers: {
          Accept: "application/json"
        },
        credentials: "same-origin"
      })

      const payload = await response.json()
      if (!response.ok) {
        this.showErrors(payload.errors || ["Unable to calculate costs."])
        return
      }

      this.updateSummary(payload)
      this.renderBreakdown(payload)
    } catch (error) {
      this.showErrors(["Network error while calculating estimate."])
    } finally {
      this.previewTarget.classList.remove("opacity-70")
    }
  }

  updateSummary(payload) {
    this.plotAreaTarget.textContent = `${this.formatNumber(payload.area.plot_area)} sqft`
    this.constructionAreaTarget.textContent = `${this.formatNumber(payload.area.construction_area)} sqft`
    this.buildableAreaTarget.textContent = `${this.formatNumber(payload.area.buildable_area)} sqft`
    this.costPerSqftTarget.textContent = this.formatCurrency(payload.summary.cost_per_sqft)

    const totalNode = this.previewTarget.querySelector(".text-3xl")
    if (totalNode) totalNode.textContent = this.formatCurrency(payload.summary.grand_total)
  }

  renderBreakdown(payload) {
    const groups = payload.materials.reduce((memo, item) => {
      memo[item.category_name] ||= []
      memo[item.category_name].push(item)
      return memo
    }, {})

    const sections = Object.entries(groups).map(([category, items]) => {
      const rows = items.map((item) => `
        <tr class="border-t border-slate-100">
          <td class="px-5 py-4 align-top">
            <p class="font-medium text-slate-900">${item.material_name}</p>
            <p class="mt-1 text-xs text-slate-500">${item.calculation_formula}</p>
          </td>
          <td class="px-5 py-4 text-right">${this.formatNumber(item.quantity)} ${item.unit}</td>
          <td class="px-5 py-4 text-right">${this.formatCurrency(item.unit_price)}</td>
          <td class="px-5 py-4 text-right font-semibold text-slate-900">${this.formatCurrency(item.total_price)}</td>
        </tr>
      `).join("")

      return `
        <section class="overflow-hidden rounded-3xl border border-slate-200">
          <div class="flex items-center justify-between bg-slate-50 px-5 py-4">
            <div>
              <p class="text-sm font-semibold text-slate-900">${category}</p>
              <p class="text-xs text-slate-500">${items.length} line items</p>
            </div>
            <p class="text-sm font-semibold text-slate-900">${this.formatCurrency(items.reduce((sum, item) => sum + item.total_price, 0))}</p>
          </div>
          <div class="overflow-x-auto bg-white">
            <table class="min-w-full divide-y divide-slate-200 text-sm text-slate-700">
              <thead class="bg-white text-xs uppercase tracking-[0.2em] text-slate-400">
                <tr>
                  <th class="px-5 py-3 text-left">Material</th>
                  <th class="px-5 py-3 text-right">Quantity</th>
                  <th class="px-5 py-3 text-right">Rate</th>
                  <th class="px-5 py-3 text-right">Amount</th>
                </tr>
              </thead>
              <tbody>${rows}</tbody>
            </table>
          </div>
        </section>
      `
    }).join("")

    this.breakdownContainerTarget.innerHTML = `${sections}
      <section class="rounded-3xl bg-slate-950 p-5 text-white">
        <div class="grid gap-4 md:grid-cols-5">
          <div><p class="text-xs uppercase tracking-[0.2em] text-slate-400">Materials</p><p class="mt-2 text-lg font-semibold">${this.formatCurrency(payload.summary.material_subtotal)}</p></div>
          <div><p class="text-xs uppercase tracking-[0.2em] text-slate-400">Labor</p><p class="mt-2 text-lg font-semibold">${this.formatCurrency(payload.summary.labor_cost)}</p></div>
          <div><p class="text-xs uppercase tracking-[0.2em] text-slate-400">Overhead</p><p class="mt-2 text-lg font-semibold">${this.formatCurrency(payload.summary.overhead_cost)}</p></div>
          <div><p class="text-xs uppercase tracking-[0.2em] text-slate-400">Contingency</p><p class="mt-2 text-lg font-semibold">${this.formatCurrency(payload.summary.contingency_cost)}</p></div>
          <div><p class="text-xs uppercase tracking-[0.2em] text-slate-400">Grand Total</p><p class="mt-2 text-lg font-semibold">${this.formatCurrency(payload.summary.grand_total)}</p></div>
        </div>
      </section>`
  }

  showErrors(messages) {
    this.errorsTarget.textContent = messages.join(" ")
    this.errorsTarget.classList.remove("hidden")
  }

  hideErrors() {
    this.errorsTarget.classList.add("hidden")
    this.errorsTarget.textContent = ""
  }

  syncSelectionStates() {
    this.qualityOptionTargets.forEach((label) => {
      const input = label.querySelector('input[type="radio"]')
      const active = input?.checked

      label.classList.toggle("border-sky-500", active)
      label.classList.toggle("bg-sky-100", active)
      label.classList.toggle("text-sky-950", active)
      label.classList.toggle("shadow-sm", active)
      label.classList.toggle("border-slate-200", !active)
      label.classList.toggle("bg-slate-50", !active)
      label.classList.toggle("text-slate-700", !active)
    })

    this.statusOptionTargets.forEach((label) => {
      const input = label.querySelector('input[type="radio"]')
      const active = input?.checked

      label.classList.toggle("border-sky-500", active)
      label.classList.toggle("bg-sky-100", active)
      label.classList.toggle("text-sky-950", active)
      label.classList.toggle("font-semibold", active)
      label.classList.toggle("border-slate-200", !active)
      label.classList.toggle("text-slate-700", !active)
    })
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-IN", { style: "currency", currency: "INR", maximumFractionDigits: 2 }).format(value || 0)
  }

  formatNumber(value) {
    return new Intl.NumberFormat("en-IN", { maximumFractionDigits: 2 }).format(value || 0)
  }
}