class BenchmarkIndicatorAction < ApplicationRecord
  include BenchmarkIndicatorActionSeed

  belongs_to :benchmark_indicator
  belongs_to :disease, optional: true
  has_many :plan_action
  has_many :action_documents, dependent: :destroy
  has_many :reference_library_documents, through: :action_documents

  scope :for_diseases_and_levels,
        ->(low:, high:) {
          where(
            "(level >= ? AND level <= ?) OR disease_id IS NOT NULL",
            low,
            high
          )
        }

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

  def as_json(options = {})
    super(
      options.reverse_merge(
        only: %i[
          id
          benchmark_indicator_id
          text
          level
          sequence
          action_types
          disease_id
        ],
        include: [:reference_library_documents],
        methods: [:benchmark_technical_area_id]
      )
    )
  end
end
