# frozen_string_literal: true

require 'spec_helper'

describe UsersController do
  describe 'GET #index' do
    context 'XHR request' do
      it 'denies access' do
        when_current_user_is :driver
        get :index, xhr: true
        expect(response).to have_http_status :unauthorized
        expect(response.body).to be_blank
      end
    end
  end
end
