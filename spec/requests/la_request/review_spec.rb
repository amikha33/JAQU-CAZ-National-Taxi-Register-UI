# frozen_string_literal: true

require 'rails_helper'

describe 'LaRequestController - GET #review', type: :request do
  subject { get review_la_request_index_path }

  context 'when no form data in session' do
    before do
      sign_in create_user
      subject
    end

    it 'returns a found response' do
      expect(response).to have_http_status(:found)
    end

    it 'redirects to the proper page' do
      expect(response).to redirect_to(la_request_index_path)
    end
  end

  context 'when form data in session' do
    before do
      sign_in create_user
      add_to_session({ la_request: { licensing_authorities: [] } })
      subject
    end

    it 'returns a success response' do
      expect(response).to have_http_status(:success)
    end

    it 'renders the view' do
      expect(response).to render_template(:review)
    end
  end
end
