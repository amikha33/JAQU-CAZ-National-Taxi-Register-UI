# frozen_string_literal: true

require 'rails_helper'

describe 'LaRequestController - GET #index', type: :request do
  subject { get la_request_index_path }

  before do
    sign_in create_user
    subject
  end

  it 'returns a success response' do
    expect(response).to have_http_status(:success)
  end

  it 'renders the view' do
    expect(response).to render_template(:index)
  end
end
