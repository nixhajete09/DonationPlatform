require 'spec_helper'

RSpec.describe 'Campaign creation route' do
  it 'returns 200 for /campaigns/new' do
    get '/campaigns/new'

    expect(last_response.status).to eq(200)
  end
end
