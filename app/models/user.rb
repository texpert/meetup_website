# frozen_string_literal: true

class User < ApplicationRecord
  has_logidze

  include Discard::Model
  self.discard_column = :deleted_at

  # Include default devise modules. Others available are: :omniauthable

  # devise-multi_email changes:
  # Replace :database_authenticatable with :multi_email_authenticatable,
  # :confirmable with :multi_email_confirmable, :validatable with :multi_email_validatable
  devise :multi_email_confirmable, :multi_email_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :timeoutable, :trackable, :multi_email_validatable

  enum :status, staged: 1, unverified: 2, active: 3, recovery: 4, expired: 5, locked: 6, suspended: 7,
       disabled: 8, _default: "staged"

  has_many :emails, as: :user

  after_discard { emails.update_all(discarded_at: Time.zone.now) }
  after_undiscard { emails.update_all(discarded_at: nil) }
end
