# frozen_string_literal: true

namespace :versions do
  desc 'Reserialze version data as JSON'
  task reserialize: :environment do
    object_unmigrated = PaperTrail::Version.where(object: nil).where.not(old_object: nil)
    object_changes_unmigrated = PaperTrail::Version.where(object_changes: nil).where.not(old_object_changes: nil)

    object_unmigrated.or(object_changes_unmigrated).find_each do |version|
      if version[:old_object] && version[:object].nil?
        from_yaml = PaperTrail::Serializers::YAML.load(version[:old_object])
        to_json = PaperTrail::Serializers::JSON.dump(from_yaml)
        version.update_column(:object, to_json)
      end

      if version[:old_object_changes] && version[:object_changes].nil?
        from_yaml = PaperTrail::Serializers::YAML.load(version[:old_object_changes])
        to_json = PaperTrail::Serializers::JSON.dump(from_yaml)
        version.update_column(:object_changes, to_json)
      end
    end
  end
end
