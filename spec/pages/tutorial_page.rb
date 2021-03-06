require 'page-object'

class TutorialPage
  include PageObject

  page_url "http://localhost:9292/tutorials"

  text_field(:description, name: 'description')
  text_area(:usernames, name: 'usernames')
  text_area(:badges, name: 'badges')
  button(:check_button, id: 'btn-search')
  table(:results_table, class: 'table')

  def click_check_button
    check_button
  end

  def same_usernames_as?(names_a)
    names_a.sort == self.usernames.split("\n").sort
  end

  def search_tutorial(description, usernames_a, badges_a)
    self.description = description
    self.usernames = usernames_a.join("\n")
    self.badges = badges_a.join("\n")
    click_check_button
  end

  def result_for(username)
    row = results_table_element.select { |e| e.text.match(/#{username}/) }
                               .first.map(&:text)
    name_col = row[0].split("\n")
    OpenStruct.new(username: name_col[0], status: name_col[1],
                   missing: row[1], late: row[2])
  end
end
