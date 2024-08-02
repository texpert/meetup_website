# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  def index
    @subscriptions = current_account.subscriptions.all
  end

  def create
    @subscription = current_account.subscriptions.build(subscription_params)
  end

  private

  def set_subscription
    @subscription = current_account.subscriptions.find(params[:id])
  end
end
