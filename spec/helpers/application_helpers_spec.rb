# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  describe '.support_service_email' do
    subject { helper.support_service_email }

    it 'returns a proper value' do
      expect(subject).to eq('TaxiPHVDatabase.Support@informed.com')
    end
  end
end
