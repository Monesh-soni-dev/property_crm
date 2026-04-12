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
  def sidebar_item(label, path, icon, badge: nil, badge_color: "brand")
    active = request.path.start_with?(path.to_s)
    active_css = active ? "bg-blue-50 text-blue-800 font-medium" : "text-gray-500 hover:bg-stone-100 hover:text-gray-800"
    badge_css  = { "accent" => "bg-[#e8834a]", "red" => "bg-red-500", "brand" => "bg-[#1a2e4a]" }

    link_to path, class: "flex items-center gap-2.5 px-2.5 py-2 rounded-lg text-sm transition #{active_css}" do
        concat inline_svg(icon, class: "w-3.5 h-3.5 flex-shrink-0 opacity-70")
        concat content_tag(:span, label)
        if badge && badge > 0
        concat content_tag(:span, badge,
            class: "ml-auto #{badge_css[badge_color]} text-white rounded-full px-1.5 py-px text-[10px] font-semibold")
        end
    end
  end
end