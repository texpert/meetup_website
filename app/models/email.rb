# frozen_string_literal: true

class Email < ApplicationRecord
  KIND = { 1 => :contact, 2 => :recovery, 3 => :alternative }.freeze
  KIND_VALUES = KIND.keys.freeze

  include Discard::Model

  has_logidze

  attr_readonly :account_email

  enum :status, unverified: 1, verified: 2, unreachable: 3

  belongs_to :owner, -> { with_discarded }, polymorphic: true

  validate :kind_values_legit, on: %i[create update]

  def kind_values_legit
    errors.add(:kind, :invalid) if kind_changed? && !kind_before_type_cast.is_a?(Array)
    errors.add(:kind, :invalid) unless (kind - KIND_VALUES).empty?
  end
end
