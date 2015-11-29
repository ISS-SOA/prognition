require_relative 'spec_helper'
require 'page-object'

describe 'Prognition Stories' do
  include PageObject::PageFactory

  before do
    unless @browser
      @headless = Headless.new
      @browser = Watir::Browser.new
    end
  end

  describe 'Visiting the home page' do
    it 'finds the title' do
      visit HomePage do |page|
        page.title.must_equal 'Prognition'
        page.cadet_link_element.exists?.must_equal true
        page.tutorial_link_element.exists?.must_equal true
      end
    end
  end

  describe 'Searching for a cadet' do
    it 'finds the example' do
      visit CadetPage do |page|
        page.click_example

        page.user_header.must_equal 'chenlizhan'
        page.from_date.must_equal 'Jul-15-2014'
        page.til_date.must_equal 'Jul-29-2014'
        page.number_of_badges_shown.must_equal 32
      end
    end

    it 'finds a real user' do
      # GIVEN
      visit CadetPage do |page|
        # WHEN
        page.find_cadet_badges('soumya.ray', 'May-01-2014', 'May-30-2014')

        # THEN
        page.user_header.must_equal 'soumya.ray'
        page.from_date.must_equal 'May-01-2014'
        page.til_date.must_equal 'May-30-2014'
        page.number_of_badges_shown.must_equal 12
      end
    end
  end

  describe 'Creating a new tutorial query' do
    it 'can search a new tutorial' do
      # GIVEN
      visit TutorialPage do |page|
        # WHEN
        page.description = 'Automated Test'
        page.usernames = "soumya.ray\nchenlizhan"
        page.badges = 'Object-Oriented Programming II'
        page.click_check_button

        # THEN
        page.browser.url.must_match %r{http.*/tutorials/.*}
        page.usernames.must_equal "soumya.ray\nchenlizhan"
        page.badges.must_equal 'Object-Oriented Programming II'

        ray = page.result_for 'soumya.ray'
        ray.status.must_equal '1 missing'
        ray.missing.must_equal 'Object-Oriented Programming II'

        lee = page.result_for 'chenlizhan'
        lee.status.must_equal 'none missing'
        lee.missing.must_equal ''
      end
    end
  end

  after do
    @browser.close
    # @headless.destroy
  end
end
