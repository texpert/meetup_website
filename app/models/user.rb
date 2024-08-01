class User < ApplicationRecord
  include Rodauth::Rails.model
  include Discard::Model

  has_logidze

  enum :status, unverified: 1, verified: 2, closed: 3

  has_many :subscriptions, -> { with_discarded }, as: :owner, dependent: :destroy

  def plan
    subscriptions.active.first&.plan
  end
end
