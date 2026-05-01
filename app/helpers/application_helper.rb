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
  
  def format_currency(amount)
    return 'N/A' if amount.blank?
    
    "₹#{number_to_human(amount, units: { thousand: 'L', lakh: 'Cr' })}"
  end
end
