User.create! name: 'David Faulkenberry',
             email: 'dave@example.com',
             password: 'password',
             password_confirmation: 'password',
             staff: true

User.create! name: 'Karin Eichelman',
             email: 'karin@example.com',
             password: 'password',
             password_confirmation: 'password',
             staff: false

Incident.create! driver: 'Adam Sherson',
                 occurred_at: DateTime.current,
                 shift: '30-3 AM',
                 route: '30',
                 vehicle: '3215',
                 location: 'Main St.',
                 action_before: 'Stopped',
                 action_during: 'Stopped',
                 weather_conditions: 'Rainy',
                 light_conditions: 'Gray',
                 road_conditions: 'Wet',
                 camera_used: false,
                 injuries: false,
                 damage: true,
                 description: 'Truck collided with mirror.'
