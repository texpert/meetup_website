# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]

  def index
    @subscriptions = current_user.subscriptions.all
  end

  def show
  end

  def new
    @subscription = current_user.subscriptions.new
  end

  # GET /posts/1/edit
  def edit
  end

  def create
    @subscription = current_user.subscriptions.new(subscription_params)
  end

  private

  def set_subscription
    @subscription = current_user.subscriptions.find(params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(:name, :plan_id)
  end
end
