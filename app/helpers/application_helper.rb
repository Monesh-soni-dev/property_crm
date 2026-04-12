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
end
