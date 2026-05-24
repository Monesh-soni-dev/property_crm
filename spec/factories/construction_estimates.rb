FactoryBot.define do
  factory :construction_estimate do
    association :user
    plot_length { 30 }
    plot_width { 40 }
    construction_area { 1600 }
    number_of_floors { 2 }
    city { 'Bangalore' }
    quality_tier { 'standard' }
    status { 'draft' }
  end
end