# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'layouts/_footer.html.haml', type: :view do
  it 'displays correct license' do
    render
    expect(rendered).to match(/Open Government Licence v3.0/)
  end
end
