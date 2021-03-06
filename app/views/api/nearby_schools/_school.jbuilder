json.state school[:state]
json.id school[:id]
json.name school[:name]
json.city school.dig(:address,:city)
json.type school[:schoolType]
json.level school[:gradeLevels]
json.gs_rating school[:rating]
json.average_rating school[:parentRating]
json.number_of_reviews school[:numReviews]
json.distance school[:distance]
json.links(
  show: school_path(
    nil,
    id: school[:id],
    name: school[:name],
    city: school.dig(:address,:city),
    state_name: States.state_name(school[:state])
  )
)
