import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    length: { type: Number, default: 0 },
    width: { type: Number, default: 0 },
    constructionArea: { type: Number, default: 0 }
  }

  connect() {
    this.draw()
  }

  lengthValueChanged() { this.draw() }
  widthValueChanged() { this.draw() }
  constructionAreaValueChanged() { this.draw() }

  draw() {
    const length = this.lengthValue
    const width = this.widthValue
    const constructionArea = this.constructionAreaValue

    if (length <= 0 || width <= 0) {
      this.canvasTarget.innerHTML = `
        <div class="flex items-center justify-center" style="min-height: 250px;">
          <p class="text-sm text-slate-400">Enter plot dimensions to see visualization</p>
        </div>`
      return
    }

    const plotArea = length * width
    const containerWidth = this.canvasTarget.clientWidth - 40
    const maxHeight = 300
    const scale = Math.min(containerWidth / length, maxHeight / width, 8)
    const svgWidth = length * scale + 80
    const svgHeight = width * scale + 80
    const offsetX = 40
    const offsetY = 30

    const plotW = length * scale
    const plotH = width * scale

    // Calculate setback (10% on each side)
    const setback = 0.10
    const buildableW = plotW * (1 - 2 * setback)
    const buildableH = plotH * (1 - 2 * setback)
    const buildableX = offsetX + plotW * setback
    const buildableY = offsetY + plotH * setback

    // Construction area ratio
    const buildableArea = (length * (1 - 2 * setback)) * (width * (1 - 2 * setback))
    const constRatio = constructionArea > 0 ? Math.min(constructionArea / buildableArea, 1) : 0
    const constW = buildableW * Math.sqrt(constRatio)
    const constH = buildableH * Math.sqrt(constRatio)
    const constX = buildableX + (buildableW - constW) / 2
    const constY = buildableY + (buildableH - constH) / 2

    this.canvasTarget.innerHTML = `
      <svg width="100%" viewBox="0 0 ${svgWidth} ${svgHeight + 30}" class="mx-auto">
        <!-- Plot boundary -->
        <rect x="${offsetX}" y="${offsetY}" width="${plotW}" height="${plotH}"
              fill="#f8fafc" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6,3" rx="4"/>

        <!-- Buildable area -->
        <rect x="${buildableX}" y="${buildableY}" width="${buildableW}" height="${buildableH}"
              fill="#dbeafe" stroke="#3b82f6" stroke-width="1.5" stroke-dasharray="4,2" rx="3" opacity="0.5"/>

        <!-- Construction area -->
        ${constRatio > 0 ? `
        <rect x="${constX}" y="${constY}" width="${constW}" height="${constH}"
              fill="#3b82f6" stroke="#1d4ed8" stroke-width="2" rx="3" opacity="0.3"/>
        <text x="${constX + constW / 2}" y="${constY + constH / 2}"
              text-anchor="middle" dominant-baseline="middle"
              class="text-xs" fill="#1e40af" font-weight="600" font-size="11">
          ${constructionArea.toLocaleString()} sqft
        </text>
        ` : ''}

        <!-- Dimension labels -->
        <text x="${offsetX + plotW / 2}" y="${offsetY - 8}"
              text-anchor="middle" fill="#475569" font-size="12" font-weight="500">
          ${length} ft
        </text>
        <text x="${offsetX - 8}" y="${offsetY + plotH / 2}"
              text-anchor="middle" fill="#475569" font-size="12" font-weight="500"
              transform="rotate(-90, ${offsetX - 8}, ${offsetY + plotH / 2})">
          ${width} ft
        </text>

        <!-- Legend -->
        <rect x="${offsetX}" y="${svgHeight + 5}" width="12" height="12" fill="#f8fafc" stroke="#94a3b8" stroke-width="1" rx="2"/>
        <text x="${offsetX + 16}" y="${svgHeight + 15}" fill="#64748b" font-size="10">Plot (${plotArea.toLocaleString()} sqft)</text>

        <rect x="${offsetX + 140}" y="${svgHeight + 5}" width="12" height="12" fill="#dbeafe" stroke="#3b82f6" stroke-width="1" rx="2" opacity="0.5"/>
        <text x="${offsetX + 156}" y="${svgHeight + 15}" fill="#64748b" font-size="10">Buildable</text>

        <rect x="${offsetX + 230}" y="${svgHeight + 5}" width="12" height="12" fill="#3b82f6" stroke="#1d4ed8" stroke-width="1" rx="2" opacity="0.3"/>
        <text x="${offsetX + 246}" y="${svgHeight + 15}" fill="#64748b" font-size="10">Construction</text>
      </svg>`
  }
}
