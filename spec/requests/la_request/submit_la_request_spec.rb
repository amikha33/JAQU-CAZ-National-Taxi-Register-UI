# frozen_string_literal: true

require 'rails_helper'

describe 'LaRequestController - POST #submit_la_request', type: :request do
  subject { post la_request_index_path, params: }

  let(:params) { { la_request_form: { name:, email:, details: } } }
  let(:name) { 'Joe Bloggs' }
  let(:email) { 'joe.bloggs@informed.com' }
  let(:details) { 'I need to reset my email address' }
  let(:licensing_authorities) { file_fixture('responses/authority_response.json').read }

  before do
    sign_in(create_user)
    allow(AuthorityApi).to receive(:licensing_authorities).and_return([licensing_authorities])
  end

  context 'when request is valid' do
    it 'renders request review page' do
      expect(subject).to redirect_to(review_la_request_index_path)
    end
  end

  context 'when request is invalid' do
    let(:name) { '' }

    it 'renders index page' do
      expect(subject).to render_template(:index)
    end
  end
end
