require 'spec_helper'

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
      expect { import! }.to change(User.active, :count).by 1
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
    it 'imports users as drivers' do
      import!
      expect(User.last).to be_driver
    end
    context 'invalid user data' do
      let(:division) { '' }
      it 'does not import the user' do
        expect { import! }.not_to change User.active, :count
      end
      it 'marks a rejected record' do
        statuses = import!
        expect(statuses).to have_key :rejected
        expect(statuses[:rejected]).to be 1
      end
    end
    context 'user already exists' do
      before :each do
        umass = create :division, name: 'UMASS'
        create :user, :driver, first_name: 'John',
          last_name: 'Smith', badge_number: 1234,
          divisions: [umass]
      end
      it 'does not re-import them' do
        expect { import! }.not_to change User.active, :count
      end
      context 'user has not changed since last import' do
        it 'does not mark them as updated' do
          statuses = import!
          expect(statuses[:imported]).not_to be 1
        end
      end
      context 'user name has changed' do
        let(:last_name) { 'Woodall' }
        it 'changes their name' do
          import!
          expect(User.last.last_name).to eql 'Woodall'
        end
      end
      context 'user job class has changed' do
        let(:job_class) { 'Supervisor' }
        it 'changes their job class' do
          import!
          expect(User.last).to be_supervisor
        end
      end
      context 'user division has changed' do
        # Could've modeled it more simply, but this is the real use case.
        # On the site, people can belong to multiple divisions.
        # This is not the case in Hastus.
        # So we don't want importing user data to suddenly restrict
        # staff members' access.
        before :each do
          satco = create :division, name: 'SATCO'
          User.last.divisions << satco
        end
        it 'does nothing' do
          expect(User.last.divisions.count).to be 2
          import!
          expect(User.last.divisions.count).to be 2
        end
      end
      context 'user Hastus ID / badge number has changed' do
        let(:hastus_id) { 5678 }
        it 'imports a new user' do # because this is how we identify users
          statuses =import!
          expect(statuses[:imported]).to be 1
        end
      end
      context 'changing to invalid data' do
        let(:first_name) { '' }
        it 'rejects the change' do
          statuses = import!
          expect(statuses[:rejected]).to be 1
        end
      end
    end
    context 'job class of supervisor' do
      let(:job_class) { 'Supervisor' }
      it 'imports the user as a supervisor' do
        import!
        expect(User.last).to be_supervisor
      end
    end
    context 'someone is not present in the XML' do
      let!(:old_user) { create :user }
      it 'deactivates them' do
        import!
        expect(old_user.reload).not_to be_active
      end
      it 'reports a deactivation' do
        statuses = import!
        expect(statuses[:deactivated]).to be 1
      end
      context 'that person is staff' do
        let!(:old_user) { create :user, :staff }
        it 'does not deactivate them' do
          statuses = import!
          expect(old_user.reload).to be_active
          expect(statuses[:deactivated]).not_to be 1
        end
      end
    end
  end
end
