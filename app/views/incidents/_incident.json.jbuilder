json.extract! incident, :id, :driver, :occurred_at, :shift, :route, :vehicle, :location, :action_before, :action_during, :weather_conditions, :light_conditions, :road_conditions, :camera_used, :injuries, :damage, :description, :created_at, :updated_at
json.url incident_url(incident, format: :json)
