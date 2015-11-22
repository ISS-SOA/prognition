require_relative 'spec_helper'
require 'json'


describe 'Prognition Stories' do
  before do
    unless @browser
      @headless = Headless.new
      @browser = Watir::Browser.new
    end
    @browser.goto 'localhost:9292'
  end

  describe 'Visiting the home page' do
    it 'finds the title' do
      @browser.title.must_equal 'Prognition'
    end
  end

  describe 'Searching for a cadet' do
    it 'finds a real user' do
      @browser.link(text: '(see example)').click
      @browser.h1(class: 'username').text.must_equal 'chenlizhan'
      @browser.input(name: 'from_date').value.must_equal 'Jul-15-2014'
      @browser.input(name: 'til_date').value.must_equal 'Jul-29-2014'
      @browser.table(class: 'table').rows.count.must_be :>=, 33
      @browser.svg.exists?.must_equal true
    end
  end

  describe 'Creating a new tutorial query' do
    it 'can search a new tutorial' do
      @browser.link(text: 'Check a Group').click
      @browser.text_field(name: 'description').set('Automated Test')
      @browser.textarea(name: 'usernames').set("soumya.ray\nchenlizhan")
      @browser.textarea(name: 'badges').set('Object-Oriented Programming II')
      @browser.button(id: 'btn-search').click

      @browser.url.must_match %r{http.*/tutorials/.*}
      @browser.li(class: 'active').text.must_equal 'Check a Group'
      @browser.textarea(name: 'usernames').text.must_equal "soumya.ray\nchenlizhan"
      @browser.textarea(name: 'badges').text.must_equal 'Object-Oriented Programming II'
      @browser.table(class: 'table').rows[1].text.must_match(/soumya.ray/)
      @browser.table(class: 'table').rows[1].text.must_match(/1 missing/)
      @browser.table(class: 'table').rows[1].text.must_match(/Object-Oriented Programming II/)
      @browser.table(class: 'table').rows[2].text.must_match(/chenlizhan/)
      @browser.table(class: 'table').rows[2].text.must_match(/none missing/)
    end
  end

  # after do
  #   @browser.close
  #   @headless.destroy
  # end
end
