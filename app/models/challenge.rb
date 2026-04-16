class Challenge < ApplicationRecord
  has_many :attempts, dependent: :destroy

  validates :name, presence: true
end
