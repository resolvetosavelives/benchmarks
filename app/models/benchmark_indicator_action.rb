class BenchmarkIndicatorAction < ApplicationRecord
  include BenchmarkIndicatorActionSeed

  belongs_to :benchmark_indicator
  belongs_to :disease, optional: true
  has_many :plan_action
  has_and_belongs_to_many :reference_library_documents,
                          join_table: :actions_and_documents

  default_scope { order(:sequence) }

  delegate :benchmark_technical_area_id, to: :benchmark_indicator

  # Note that these values are 0-indexed but in the DB they are 1-indexed
  ACTION_TYPES = [
    "Advocacy",
    "Assessment and Data Use",
    "Coordination",
    "Designation",
    "Dissemination",
    "Financing",
    "Monitoring and Evaluation",
    "Planning and Strategy",
    "Procurement",
    "Program Implementation",
    "SimEx and AAR",
    "SOPs",
    "Surveillance",
    "Tool Development",
    "Training"
  ].freeze

  # defines how JSON will be formed with +to_json+ and +as_json+
  def attributes
    {
      id: nil,
      benchmark_indicator_id: nil,
      benchmark_technical_area_id: nil,
      text: nil,
      level: nil,
      sequence: nil,
      action_types: nil,
      disease_id: nil
    }
  end

  def action_types
    self[:action_types] || []
  end

  def documents_by_type
    reference_library_documents.reduce({}) do |type_hash, doc|
      type_sym =
        doc.reference_type.parameterize(separator: "_").pluralize.to_sym

      type_hash[type_sym] = [] if type_hash[type_sym].nil?
      type_hash[type_sym] << doc
      type_hash
    end
  end

  def as_json(*args, **kwargs)
    super(*args, **kwargs).merge(
      "reference_library_documents" => reference_library_documents.as_json
    )
  end
end
