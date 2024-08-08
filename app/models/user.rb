# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model

  enum :status, staged: 1, unverified: 2, active: 3, recovery: 4, expired: 5, locked: 6, suspended: 7,
       disabled: 8, _default: "staged"

  has_many :emails, as: :user, dependent: :destroy

  # Include default devise modules. Others available are: :omniauthable

  # devise-multi_email changes:
  # Replace :database_authenticatable with :multi_email_authenticatable,
  # :confirmable with :multi_email_confirmable, :validatable with :multi_email_validatable
  devise :multi_email_confirmable, :multi_email_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :timeoutable, :trackable, :multi_email_validatable
end
