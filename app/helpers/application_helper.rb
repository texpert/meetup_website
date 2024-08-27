# frozen_string_literal: true

module ApplicationHelper
  def render_modal(title: '', body: '', footer: '')
    render(partial: '/partials/modal', locals: { title:, body:, footer: })
  end
end
