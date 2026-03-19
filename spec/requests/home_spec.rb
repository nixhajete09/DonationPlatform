# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Home page' do
  it 'returns 200 on GET /' do
    get '/'

    expect(last_response.status).to eq(200)
  end
end
