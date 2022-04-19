# frozen_string_literal: true

require 'rails_helper'

describe ExampleCsv do
  subject(:service_call) { described_class.call(lines:, dir:) }

  let(:lines) { 5 }
  let(:dir) { 'tmp/example_files_test' }

  after { FileUtils.rm_rf(dir) }

  it 'creates CSV file' do
    service_call
    expect(File).to exist("#{dir}/CAZ-#{Date.current.iso8601}-ABCDE.csv")
  end
end
