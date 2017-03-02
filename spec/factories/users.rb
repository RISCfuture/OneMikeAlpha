FactoryBot.define do
  factory :user do
    sequence(:username) { |i| FFaker::Internet.user_name + "-#{i}" }
    password { FFaker::Internet.password }
  end
end
