# frozen_string_literal: true

require 'rails_helper'

describe LaRequestForm do
  subject { described_class.new(la_params) }

  let(:la_params) { { name:, email:, details: } }
  let(:name) { 'Joe Bloggs' }
  let(:email) { 'joe.bloggs@informed.com' }
  let(:details) { 'I need to reset my email address' }

  before { subject.valid? }

  it 'is valid with proper params' do
    expect(subject).to be_valid
  end

  context 'when `name`, `email` and `details` are empty' do
    let(:name) { '' }
    let(:email) { '' }
    let(:details) { '' }

    it 'is not valid' do
      expect(subject).not_to be_valid
    end

    it 'has a proper `name` error message' do
      expect(error_message(:name)).to eq('Enter your full name')
    end

    it 'has a proper `email` error message' do
      expect(error_message(:email)).to eq('Enter your email address')
    end

    it 'has a proper `details` error message' do
      expect(error_message(:details)).to eq('Enter your request details')
    end
  end

  context 'when `email` is not in a valid format' do
    let(:name) { 'Joe Bloggs' }
    let(:email) { 'email.address' }
    let(:details) { 'I need to reset my email address' }

    it 'is not valid' do
      expect(subject).not_to be_valid
    end

    it 'has proper `email` error message' do
      expect(error_message(:email)).to eq('Enter your email address in a valid format')
    end
  end

  private

  def error_message(attribute)
    subject.errors.messages[attribute].first
  end
end
