# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Users' do
  describe 'GET /create' do
    it 'returns http success' do
      get '/admin/users/create'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      get '/admin/users/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/admin/users/show'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /update' do
    it 'returns http success' do
      get '/admin/users/update'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /discard' do
    it 'returns http success' do
      get '/admin/users/discard'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /destroy' do
    it 'returns http success' do
      get '/admin/users/destroy'
      expect(response).to have_http_status(:success)
    end
  end
end
