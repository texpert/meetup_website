# frozen_string_literal: true

module ApplicationHelper
  def render_modal(title: '', body: '', footer: '')
    render(partial: '/partials/modal', locals: { title:, body:, footer: })
  end

  def disable_link_if_page(page, tag_class: '')
    if current_page?(page)
      { class: "#{tag_class} active", style: 'pointer-events: none; touch-action: none', tabindex: -1 }
    else
      { class: tag_class, style: 'pointer-events: inherit; touch-action: inherit', tabindex: 0 }
    end
  end
end
