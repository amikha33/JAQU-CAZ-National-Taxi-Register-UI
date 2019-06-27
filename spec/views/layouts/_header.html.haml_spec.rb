# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'layouts/_header.html.haml', type: :view do
  it 'displays correct title' do
    render
    expect(rendered).to match(/Clean Air Zones/)
  end
end
