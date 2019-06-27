# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'layouts/_feedback_section.html.haml', type: :view do
  it 'displays feedback text' do
    render
    expect(rendered).to match(/feedback/)
  end
end
