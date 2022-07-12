# frozen_string_literal: true

require 'rails_helper'

describe 'PasswordsController - GET #reset', type: :request do
  subject { get reset_passwords_path }

  let(:user) { User.new }

  it 'returns a 200 OK status' do
    subject
    expect(response).to have_http_status(:ok)
  end

  it 'renders reset template' do
    subject
    expect(response).to render_template(:reset)
  end
end
