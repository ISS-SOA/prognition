require 'page-object'

class CadetPage
  include PageObject

  page_url "http://localhost:9292/cadets"

  link(:click_example, text: '(see example)')
  text_field(:username, id: 'username-input')
  text_field(:from_date, name: 'from_date')
  text_field(:til_date, name: 'til_date')
  button(:click_search, id: 'submit-button')
  h1(:user_header, class: 'username')
  table(:results_table, class: 'table')
  div(:chart, id: 'progress')

  def badges_shown
    results_table_element.rows-1
  end
end
