json.array!(@recommendations) do |recommendation|
  json.extract! recommendation, :id, :like, :description, :user_id, :restaurant_id
  json.url recommendation_url(recommendation, format: :json)
end
