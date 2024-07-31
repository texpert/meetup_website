class User < ApplicationRecord
  include Rodauth::Rails.model

  has_logidze

  enum :status, unverified: 1, verified: 2, closed: 3
end
