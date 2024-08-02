# frozen_string_literal: true

class Profile < ApplicationRecord
  include Discard::Model

  has_logidze

  belongs_to :user

  enum :gender, male: 1, female: 2

  validates :full_name, presence: true, on: %i[create update]
end
