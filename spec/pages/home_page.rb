require 'page-object'

class HomePage
  include PageObject

  page_url "http://localhost:9292/cadets"

  link(:cadet_link, text: 'Search for a Cadet')
  link(:tutorial_link, text: 'Check a Group')
end
