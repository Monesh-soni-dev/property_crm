module ConstructionEstimatesHelper
  def number_to_indian_currency(amount)
    return "₹0" if amount.blank? || amount.to_f <= 0

    val = amount.to_f
    if val >= 10_000_000
      "₹#{'%.2f' % (val / 10_000_000.0)} Cr"
    elsif val >= 100_000
      "₹#{'%.2f' % (val / 100_000.0)} L"
    else
      "₹#{number_with_delimiter(val.round(2))}"
    end
  end

  def quality_tier_badge(tier)
    colors = {
      "basic" => "bg-gray-100 text-gray-700 border-gray-200",
      "standard" => "bg-blue-100 text-blue-700 border-blue-200",
      "premium" => "bg-amber-100 text-amber-700 border-amber-200"
    }
    css = colors[tier.to_s] || colors["standard"]
    content_tag(:span, tier.to_s.capitalize,
      class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold border #{css}")
  end

  def status_badge(status)
    colors = {
      "draft" => "bg-yellow-100 text-yellow-800",
      "finalized" => "bg-green-100 text-green-800"
    }
    css = colors[status.to_s] || "bg-gray-100 text-gray-800"
    content_tag(:span, status.to_s.capitalize,
      class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold #{css}")
  end

  def cost_percentage(part, total)
    return 0 if total.to_f.zero?
    ((part.to_f / total.to_f) * 100).round(1)
  end
end
