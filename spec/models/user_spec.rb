require 'rails_helper'

describe User do
  describe '.import_from_xml' do
    let :import! do
      xml = Nokogiri::XML.parse xml_text
      User.import_from_xml(xml)
    end
    let :xml_text do
      <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <object_interface xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <User>
            <hastus_id>#{hastus_id}</hastus_id>
            <last_name>#{last_name}</last_name>
            <first_name>#{first_name}</first_name>
            <job_class>#{job_class}</job_class>
            <division>#{division}</division>
          </User>
        </object_interface>
      XML
    end
    let(:hastus_id) { 1234 }
    let(:last_name) { 'SMITH' }
    let(:first_name) { 'JOHN' }
    let(:job_class) { 'Driver' }
    let(:division) { 'UMASS' }

    it 'imports users from the provided XML (base case)' do
      expect { import! }.to change(User, :count).by 1
    end
    it 'returns some statuses' do
      statuses = import!
      expect(statuses).to have_key :imported
      expect(statuses[:imported]).to be 1
    end
    it 'capitalizes names' do
      import!
      expect(User.last).to have_attributes first_name: 'John', last_name: 'Smith'
    end
  end
end
