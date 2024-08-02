class User < ApplicationRecord
  include Rodauth::Rails.model
  include Discard::Model

  has_logidze

  enum :status, staged: 1, unverified: 2, active: 3, recovery: 4, expired: 5, locked: 6, suspended: 7, disabled: 8

  has_many :subscriptions, -> { with_discarded }, as: :owner, dependent: :destroy

  def plan
    subscriptions.active.first&.plan
  end
end
