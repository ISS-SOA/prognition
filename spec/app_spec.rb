require_relative 'spec_helper'
require 'json'


describe 'Prognition Stories' do
  before do
    @headless = Headless.new
    @browser = Watir::Browser.new
    @browser.goto 'localhost:9292'
  end

  describe 'Visiting the home page' do
    it 'find the title' do
      @browser.title.must_equal 'Prognition'
    end
  end

  describe 'Searching for a cadet' do
    it 'finds a real user' do
      @browser.link(:text, '(see example)').click
      @browser.h1(class: 'username').text.must_equal 'chenlizhan'
      @browser.input(name: 'from_date').value.must_equal 'Jul-15-2014'
      @browser.input(name: 'til_date').value.must_equal 'Jul-29-2014'
      @browser.table(class: 'table').rows.count.must_be :>=, 33
      @browser.svg.exists?.must_equal true
    end
  end

  after do
    @browser.close
    @headless.destroy
  end
end
