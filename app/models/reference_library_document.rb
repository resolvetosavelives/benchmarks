class ReferenceLibraryDocument < ApplicationRecord
  include ReferenceLibraryDocumentSeed

  has_many :action_documents, dependent: :destroy
  has_many :benchmark_indicator_actions, through: :action_documents

  validates :download_url, uniqueness: true

  # returns an array of reference_type strings sorted alphabetically
  def self.distinct_types
    self.select(:reference_type).distinct.pluck(:reference_type).sort
  end

  def self.reference_type_ordinal(reference_type_name)
    index = distinct_types.index(reference_type_name)
    return nil if index.nil?

    index + 1
  end

  def reference_type_ordinal
    ReferenceLibraryDocument.reference_type_ordinal(reference_type)
  end
end
