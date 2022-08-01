# frozen_string_literal: true

require 'rails_helper'

describe 'LaRequestController - POST #submit_review', type: :request do
  subject { post review_la_request_index_path }

  let(:name) { 'Joe Bloggs' }
  let(:email) { 'joe.bloggs@informed.com' }
  let(:details) { 'I need to reset my email address' }
  let(:licensing_authorities) { file_fixture('responses/authority_response.json').read }

  before do
    sign_in(create_user)
    add_to_session({ la_request: { licensing_authorities: [] } })
    allow(AuthorityApi).to receive(:licensing_authorities).and_return([licensing_authorities])
    allow(LaRequestDvlaMailer).to receive(:call)
    allow(LaRequestLaMailer).to receive(:call)
    subject
  end

  context 'when request is valid' do
    it 'sets :success flash message' do
      expect(flash[:success]).to eq('You have successfully submitted a request, a confirmation email has been sent.')
    end

    it 'redirects to request confirmation page' do
      expect(subject).to redirect_to authenticated_root_path
    end
  end
end
