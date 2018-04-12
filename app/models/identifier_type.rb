class IdentifierType < ActiveRecord::Base
  belongs_to :owner_app, required: true, class_name: 'App', inverse_of: :identifier_types

  validates :name, presence: true, uniqueness: true

  validate :name_must_be_snake_case

  private

  def name_must_be_snake_case
    errors[:name] << "must be snake_case: #{name.inspect}" if name_not_underscored?
  end

  def name_not_underscored?
    name && !underscored?(name)
  end

  def underscored?(string)
    string.to_s == string.to_s.underscore
  end
end
