class Prompt < ApplicationRecord
  validates :prompt_id, presence: true, uniqueness: true
end
