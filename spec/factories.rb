FactoryGirl.define do
  factory :experiment do
    title "Don't do Drugs"
    publication
    submitted true
    submitted_at Time.now
  end

  factory :publication do
    title "Drugs are Bad"
  end
end