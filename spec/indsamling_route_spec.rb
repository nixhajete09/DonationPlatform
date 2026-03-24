require 'spec_helper'

RSpec.describe 'Indsamling route' do
  it 'returns 200 for /indsamling' do
    get '/indsamling'

    expect(last_response.status).to eq(200)
  end
end
