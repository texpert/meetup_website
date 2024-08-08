# frozen_string_literal: true

class Email < ApplicationRecord
  KIND = { 1 => :contact, 2 => :recovery, 3 => :alternative }.freeze
  KIND_VALUES = KIND.keys.freeze

  include Discard::Model

  attr_readonly :primary

  enum :status, untried: 1, reachable: 2, unreachable: 3, _default: 'untried'

  belongs_to :user, polymorphic: true

  validate :kind_values_legit, on: %i[create update]

  def kind_values_legit
    errors.add(:kind, :invalid) if kind_changed? && !kind_before_type_cast.is_a?(Array)
    errors.add(:kind, :invalid) unless (kind - KIND_VALUES).empty?
  end
end
