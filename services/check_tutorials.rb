require 'virtus'

##
# Value object for results from searching a tutorial set for missing badges
class TutorialResult
  include Virtus.model

  attribute :code
  attribute :id
  attribute :description
  attribute :usernames
  attribute :badges
  attribute :deadline
  attribute :late
  attribute :missing
  attribute :completed

  def to_json
    to_hash.to_json
  end
end

##
# Service object to check tutorial request from API
class CheckTutorialFromAPI
  def initialize(api_url, form)
    @api_url = api_url
    params = form.attributes.delete_if { |_, value| value.blank? }
    @options =  { body: params.to_json,
                  headers: { 'Content-Type' => 'application/json' }
                }
  end

  def call
    results = HTTParty.post(@api_url, @options)
    tutorial_results = TutorialResult.new(results)
    tutorial_results.code = results.code
    tutorial_results.id = results.request.last_uri.path.split('/').last
    tutorial_results
  end
end
