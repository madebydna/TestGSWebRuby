school.stringify_keys!
json.state school['state']
json.id school['id']
json.name school['name']
json.city school['city']
json.type school['type']
json.level school['level']
json.gs_rating school['gs_rating']
json.average_rating school['average_rating']
json.number_of_reviews school['number_of_reviews']
json.distance school['distance']
json.links(
  show: school_path(
    nil,
    id: school['id'],
    name: school['name'],
    city: school['city'],
    state_name: States.state_name(school['state'])
  )
)
