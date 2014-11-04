require_relative 'spec_helper'
require_relative 'support/cc_helper'
require 'json'

describe 'Codecadet Testing Start' do

  include CCHelper

  describe 'root path' do
    it 'should return ok' do
      get '/'
      last_response.must_be :ok?
    end
  end

  describe 'user path' do
    it 'should return ok' do
      get '/user'
      last_response.must_be :ok?
    end
  end

  describe 'group path' do
    it 'should return ok' do
      get '/group'
      last_response.must_be :ok?
    end
  end

  describe 'get user path with parameter' do
    it 'should return redirect' do
      get "/user/#{random_str(20)}"
      last_response.must_be :redirect?
    end

    it 'should return ok' do
      get "/user/chenlizhan"
      last_response.status.must_equal 200
    end
  end

  describe 'post result path' do
    it 'should return redirect' do
      body = 'chenlizhan'
      post 'result', body
      last_response.must_be :redirect?
    end
  end

  describe 'getting user\'s badges' do
    it 'should return the badges' do
      get '/api/v1/cadet/chenlizhan.json'
      last_response.must_be :ok?
    end

    it 'should return 404 error' do
      get "/api/v1/cadet/#{random_str(20)}.json"
      last_response.must_be :not_found?
    end
  end

  describe 'badges check' do
    it 'should find missing badges' do
      body = {
        usernames: "soumya.ray\r\nchenlizhan",
        badges: 'Object-Oriented Programming II'
      }

      post '/api/v1/group', body
      last_response.must_be :ok?
    end

    it 'should return unknow user' do
      body = {
        usernames: "#{random_str(20)}\r\n#{random_str(20)}",
        badges: 'Object-Oriented Programming II'
      }

      post '/api/v1/group', body
      last_response.must_be :not_found? 
    end
  end
end