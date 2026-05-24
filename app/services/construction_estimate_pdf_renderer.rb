require 'prawn'
require 'prawn/table'

class ConstructionEstimatePdfRenderer
  FONT_PATHS = {
    normal: '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    bold: '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
  }.freeze

  def initialize(construction_estimate)
    @construction_estimate = construction_estimate
  end

  def render
    Prawn::Document.new(page_size: 'A4', margin: 36) do |pdf|
      configure_fonts(pdf)

      pdf.text safe_text('Construction Cost Estimate'), size: 22, style: :bold
      pdf.move_down 4
      pdf.text safe_text("Estimate ##{@construction_estimate.id} | #{@construction_estimate.city} | #{@construction_estimate.quality_tier.titleize}"), size: 11, color: '555555'
      pdf.move_down 18

      pdf.text safe_text('Builder Details'), size: 15, style: :bold
      pdf.move_down 8
      pdf.table(builder_rows, width: pdf.bounds.width, cell_style: { borders: [], padding: [4, 0, 4, 0] })
      pdf.move_down 18

      pdf.table(summary_rows, width: pdf.bounds.width, cell_style: { borders: [], padding: [6, 0, 6, 0] })
      pdf.move_down 18

      pdf.text safe_text('Material Breakdown'), size: 15, style: :bold
      pdf.move_down 8
      pdf.table(material_rows, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'E2E8F0'
        self.cell_style = { size: 9, padding: 6 }
        columns(2..4).align = :right
      end

      pdf.move_down 18
      pdf.text safe_text('Cost Summary'), size: 15, style: :bold
      pdf.move_down 8
      pdf.table(cost_summary_rows, width: pdf.bounds.width / 1.5, position: :left) do
        self.cell_style = { size: 10, padding: 6 }
        columns(1).align = :right
      end

      pdf.move_down 18
      pdf.text safe_text('Builder Cost Inputs'), size: 15, style: :bold
      pdf.move_down 8
      pdf.table(builder_adjustment_rows, width: pdf.bounds.width, cell_style: { size: 10, padding: 6 }) do
        row(0).background_color = 'E0F2FE'
        row(0).font_style = :bold
      end
    end.render
  end

  private

  def builder_rows
    builder = @construction_estimate.user
    [
      ['Builder Name', builder.full_name],
      ['Contact Number', builder.mobile_number.presence || 'Not available'],
      ['Email', builder.email],
      ['Location', [builder.city, builder.state].compact_blank.join(', ').presence || 'Not available'],
      ['Address', builder.address.presence || 'Not available']
    ].map { |row| row.map { |value| safe_text(value) } }
  end

  def summary_rows
    [
      ['Plot Size', "#{@construction_estimate.plot_length.to_f.round(2)} ft x #{@construction_estimate.plot_width.to_f.round(2)} ft"],
      ['Plot Area', "#{@construction_estimate.plot_area.to_f.round(2)} sqft"],
      ['Construction Area', "#{@construction_estimate.construction_area.to_f.round(2)} sqft"],
      ['Floors', @construction_estimate.number_of_floors.to_s],
      ['Status', @construction_estimate.status.titleize],
      ['Prepared For', @construction_estimate.user.full_name]
    ].map { |row| row.map { |value| safe_text(value) } }
  end

  def material_rows
    rows = [['Category', 'Material', 'Quantity', 'Rate', 'Amount']]
    rows + @construction_estimate.estimate_materials.includes(material: :material_category).map do |line|
      [
        line.material.material_category&.name,
        line.material.name,
        "#{line.quantity.to_f.round(2)} #{line.material.unit}",
        currency(line.unit_price),
        currency(line.total_price)
      ].map { |value| safe_text(value) }
    end
  end

  def cost_summary_rows
    snapshot = @construction_estimate.latest_snapshot
    summary = snapshot.fetch('summary', {})

    [
      ['Materials', currency(summary['material_subtotal'])],
      ['Labor', currency(summary['labor_cost'])],
      ['Overhead', currency(summary['overhead_cost'])],
      ['Contingency', currency(summary['contingency_cost'])],
      ['Grand Total', currency(@construction_estimate.total_estimated_cost)]
    ].map { |row| row.map { |value| safe_text(value) } }
  end

  def builder_adjustment_rows
    rows = [
      ['Input', 'Value'],
      ['Market Adjustment', percentage(@construction_estimate.market_adjustment_percentage)],
      ['Labor', percentage(@construction_estimate.labor_percentage)],
      ['Overhead', percentage(@construction_estimate.overhead_percentage)],
      ['Contingency', percentage(@construction_estimate.contingency_percentage)],
      ['Electrical Rate / sqft', custom_rate(@construction_estimate.electrical_rate_per_sqft)],
      ['Plumbing Rate / sqft', custom_rate(@construction_estimate.plumbing_rate_per_sqft)]
    ]

    ConstructionEstimate.material_rate_fields.each do |field|
      rate_value = @construction_estimate.manual_material_rates[field[:key]]
      rows << ["#{field[:label]} (#{field[:unit_label]})", rate_value.present? ? currency(rate_value) : 'Market default']
    end

    rows.map { |row| row.map { |value| safe_text(value) } }
  end

  def currency(amount)
    ActionController::Base.helpers.number_to_currency(amount.to_f, unit: '₹', precision: 2)
  end

  def percentage(amount)
    "#{amount.to_f.round(2)}%"
  end

  def custom_rate(amount)
    amount.present? ? currency(amount) : 'Market default'
  end

  def configure_fonts(pdf)
    return unless FONT_PATHS.values.all? { |path| File.exist?(path) }

    pdf.font_families.update(
      'DejaVuSans' => {
        normal: FONT_PATHS[:normal],
        bold: FONT_PATHS[:bold]
      }
    )
    pdf.font('DejaVuSans')
  end

  def safe_text(value)
    value.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  end
end