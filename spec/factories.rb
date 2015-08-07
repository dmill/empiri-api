FactoryGirl.define do
  factory :experiment do
    title "Don't do Drugs"
    publication
    submitted true
    submitted_at Time.now
  end

  factory :publication do
    title "Drugs are Bad"
    after(:create) { |pub| pub.users << create(:user) }
  end

  factory :user do
    first_name "Walter"
    last_name "White"
    title "Heisenberg"
    organization "Albuquerque Unified School District"
  end
end