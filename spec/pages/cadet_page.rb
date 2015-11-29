require 'page-object'

class CadetPage
  include PageObject

  page_url "http://localhost:9292/cadets"

  link(:example_link, text: '(see example)')
  text_field(:username, id: 'username-input')
  text_field(:from_date, name: 'from_date')
  text_field(:til_date, name: 'til_date')
  button(:search_button, id: 'submit-button')
  h1(:user_header, class: 'username')
  table(:results_table, class: 'table')
  div(:chart, id: 'progress')

  def number_of_badges_shown
    results_table_element.rows-1
  end

  def click_example
    example_link
  end

  def find_cadet_badges(username_str, from_date_str, til_date_str)
    self.username = username_str
    self.from_date = from_date_str
    self.til_date = til_date_str
    search_button
  end
end
