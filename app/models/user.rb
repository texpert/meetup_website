# frozen_string_literal: true

class User < ApplicationRecord
  include Rodauth::Rails.model
  include Discard::Model

  has_logidze

  enum :status, staged: 1, unverified: 2, active: 3, recovery: 4, expired: 5, locked: 6, suspended: 7, disabled: 8

  has_many :emails, as: :owner, dependent: :destroy
  accepts_nested_attributes_for :emails

  has_many :subscriptions, -> { with_discarded }, as: :owner, dependent: :destroy

  def email
    @email ||= emails.find_by(account_email: true)
  end

  def plan
    subscriptions.active.first&.plan
  end
end
