require 'rails_helper'

RSpec.describe District, type: :model do
  it { should have_many(:facilities) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).case_insensitive }
end
