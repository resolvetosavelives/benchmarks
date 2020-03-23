# frozen_string_literal: true

require File.expand_path('./test/test_helper')
require 'minitest/spec'
require 'minitest/autorun'
require 'csv'

describe ReferenceLibraryDocument do
  describe '#extract_download_url' do
    let(:attachment_field) { 'One health zoonotic disease prioroitization for Multisectoral Engagement in Burkina Faso (FRENCH).pdf (https://dl.airtable.com/.attachments/d273fbb3427d94635ddb734a14f95e26/98c1a677/OnehealthzoonoticdiseaseprioroitizationforMultisectoralEngagementinBurkinaFasoFRENCH.pdf),One health zoonotic disease prioroitization for Multisectoral Engagement in Burkina Faso.pdf (https://dl.airtable.com/.attachments/a78a3c2b524ddac30133b6aa882817aa/15400a04/OnehealthzoonoticdiseaseprioroitizationforMultisectoralEngagementinBurkinaFaso.pdf)' }

    it 'returns the expected URL' do
      ReferenceLibraryDocument.extract_download_url(attachment_field).must_equal 'https://dl.airtable.com/.attachments/a78a3c2b524ddac30133b6aa882817aa/15400a04/OnehealthzoonoticdiseaseprioroitizationforMultisectoralEngagementinBurkinaFaso.pdf'
    end
  end

  describe '.all_from_csv' do
    let(:csv_data) { CSV.read(ReferenceLibraryDocument::PATH_TO_CSV_FILE) }
    let(:result) { ReferenceLibraryDocument.all_from_csv }

    it 'returns an array of ReferenceLibraryDocuments' do
      result.must_be_instance_of Array
      result.size.must_equal(csv_data.size - 1)
      result.first.must_be_instance_of ReferenceLibraryDocument
      result.last.must_be_instance_of ReferenceLibraryDocument
    end
  end

  describe '#new_from_csv' do
    let(:result) do
      ReferenceLibraryDocument.new_from_csv(
        'title xyz', 'desc xyz', 'author xyz', 'date xyz', 'page xyz',
        'CSV download URL', 'CSV thumbnail URL', 'Antimicrobial Resistance',
        'Case Study'
      )
    end
    before do
      ReferenceLibraryDocument.expects(:extract_download_url).with('CSV download URL').returns('test download URL')
      ReferenceLibraryDocument.stubs(:extract_download_url).with('CSV thumbnail URL').returns('test thumbnail URL')
    end

    it 'returns an instance of ReferenceLibraryDocument with its members set' do
      result.must_be_instance_of ReferenceLibraryDocument
      result.title.must_equal 'title xyz'
      result.description.must_equal 'desc xyz'
      result.author.must_equal 'author xyz'
      result.date.must_equal 'date xyz'
      result.relevant_pages.must_equal 'page xyz'
      result.download_url.must_equal 'test download URL'
      result.thumbnail_url.must_equal 'test thumbnail URL'
      result.technical_area.must_equal 'Antimicrobial Resistance'
      result.reference_type.must_equal 'Case Study'
    end
  end

  describe '.reference_type_ordinal' do
    describe 'for a known type' do
      it 'returns the expected integer' do
        ReferenceLibraryDocument.reference_type_ordinal('Briefing Note').must_equal 1
        ReferenceLibraryDocument.reference_type_ordinal('Case Study').must_equal 2
        ReferenceLibraryDocument.reference_type_ordinal('Training Package').must_equal 8
      end
    end

    describe 'for nil' do
      it 'returns nil' do
        ReferenceLibraryDocument.reference_type_ordinal(nil).must_be_nil
      end
    end

    describe 'for an invalid type' do
      it 'returns nil' do
        ReferenceLibraryDocument.reference_type_ordinal('Something Else').must_be_nil
        ReferenceLibraryDocument.reference_type_ordinal('Briefing Notes').must_be_nil
      end
    end
  end
end
