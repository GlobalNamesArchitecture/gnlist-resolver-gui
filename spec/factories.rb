# frozen_string_literal: true

FactoryGirl.define do
  factory :list_matcher do
    sequence(:filename) { |n| "nameslist-#{n}.csv" }
    token { Gnlr.token }
    input { ListMatcher.input(token) }
    output { ListMatcher.output(token, filename) }
    input_sample do
      Gnlr::CsvSampler.sample(
        File.join(__dir__, "files", "taxonid_as_id.csv"), ","
      )
    end
    after(:build) { |list_matcher| name_list_file(list_matcher.token) }
  end
end
