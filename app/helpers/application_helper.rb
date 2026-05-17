module ApplicationHelper
  def nav_link(label, path)
    active = current_page?(path) || request.path.start_with?(path.to_s)
    css = active ? "bg-white/15 text-white font-medium" : "text-white/75 hover:bg-white/10 hover:text-white"
    link_to label, path, class: "px-3.5 py-1.5 rounded-md text-sm transition #{css}"
  end

  def breadcrumbs(*crumbs)
    content_for :breadcrumbs do
      crumbs.map.with_index do |(label, path), i|
        last = i == crumbs.length - 1
        if last
          content_tag(:span, label, class: "text-gray-500 text-xs")
        else
          link_to(label, path, class: "text-blue-600 text-xs hover:underline") +
            content_tag(:span, " / ", class: "text-gray-400 text-xs mx-1")
        end
      end.join.html_safe
    end
  end
  
  # Lead dashboard helpers
  def lead_status_badge(status)
    classes = case status.to_s
              when 'new_lead'
                'bg-gray-100 text-gray-800'
              when 'contacted'
                'bg-blue-100 text-blue-800'
              when 'interested'
                'bg-green-100 text-green-800'
              when 'visit_scheduled'
                'bg-yellow-100 text-yellow-800'
              when 'negotiation'
                'bg-orange-100 text-orange-800'
              when 'closed'
                'bg-emerald-100 text-emerald-800'
              when 'rejected'
                'bg-red-100 text-red-800'
              else
                'bg-gray-100 text-gray-800'
              end
              
    content_tag :span, status.to_s.humanize, 
                class: "inline-flex px-2 py-1 text-xs font-medium rounded-full #{classes}"
  end
  
  PROPERTY_TYPE_LABELS = {
    '1bhk'             => '1 BHK Apartment',
    '2bhk'             => '2 BHK Apartment',
    '3bhk'             => '3 BHK Apartment',
    '4bhk'             => '4 BHK Apartment',
    'villa'            => 'Villa',
    'plot'             => 'Plot / Land',
    'commercial_office'=> 'Commercial Office',
    'commercial_shop'  => 'Commercial Shop',
    'warehouse'        => 'Warehouse',
    'duplex'           => 'Duplex',
    'penthouse'        => 'Penthouse',
    'apartment'        => 'Apartment',
    'studio'           => 'Studio'
  }.freeze

  def format_property_type(type)
    PROPERTY_TYPE_LABELS[type.to_s] || type.to_s.gsub('_', ' ').titleize
  end

  # Build a pagination series array: e.g. [1, :gap, 5, "6", 7, :gap, 17]
  # Current page is returned as a String, others as Integer, gaps as :gap
  def pagy_series(pagy, slots: 7)
    page = pagy.page
    last = pagy.instance_variable_get(:@last)
    return [] if last.nil? || last <= 1

    series = if last <= slots
               (1..last).to_a
             else
               half  = (slots - 1) / 2
               start = if page <= half
                         1
                       elsif page > (last - slots + half)
                         last - slots + 1
                       else
                         page - half
                       end
               s = (start...(start + slots)).to_a
               if slots >= 7
                 s[0]  = 1
                 s[1]  = :gap unless s[1]  == 2
                 s[-2] = :gap unless s[-2] == last - 1
                 s[-1] = last
               end
               s
             end

    series.map { |p| p == page ? p.to_s : p }
  end

  def format_price(amount)
    return 'Price not set' if amount.blank? || amount.to_f <= 0

    val = amount.to_f
    if val >= 10_000_000  # 1 Crore = 1,00,00,000
      cr = val / 10_000_000.0
      formatted = cr == cr.floor ? "#{cr.to_i}" : "#{'%.2f' % cr}".sub(/\.?0+$/, '')
      "₹#{formatted} Cr"
    else
      l = val / 100_000.0
      formatted = l == l.floor ? "#{l.to_i}" : "#{'%.2f' % l}".sub(/\.?0+$/, '')
      "₹#{formatted} L"
    end
  end

  def format_currency(amount)
    format_price(amount)
  end
end
