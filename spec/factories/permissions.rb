FactoryBot.define do
  factory :permission do
    user
    aircraft

    level { Permission.levels.keys.sample }
  end
end
