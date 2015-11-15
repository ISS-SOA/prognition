require 'virtus'
require 'active_model'

class CheckTutorialFromAPI
  def initialize(api_url, form)
    @api_url = api_url
    params = form.attributes.delete_if { |key, value| value.blank? }
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
# Attribute for form objects of TutorialForm
class StringStripped < Virtus::Attribute
  def coerce(value)
    value.is_a?(String)? value.strip : nil
  end
end

class ArrayOfNames < Virtus::Attribute
  def coerce(value)
    value.is_a?(String) ? value.split("\r\n").map(&:strip).reject(&:empty?) : nil
  end
end

##
# Form object TutorialForm
class TutorialForm
  include Virtus.model
  include ActiveModel::Validations

  attribute :description, StringStripped
  attribute :usernames, ArrayOfNames
  attribute :badges, ArrayOfNames
  attribute :deadline, Date

  validates :description, presence: true
  validates :usernames, presence: true
  validates :badges, presence: true
end
