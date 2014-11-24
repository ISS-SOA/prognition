[ ![Codeship Status for ISS-SOA/codecadet](https://www.codeship.io/projects/b0a69d80-4644-0132-25b4-2602dd94dcef/status)](https://www.codeship.io/projects/45237)

API v1 Routes:
- GET /api/v1/cadet/:username.json
  - take :username (the codecademy username)
  - return JSON of badges for the username
- POST /api/v1/group
  - usernames (a collection of usernames, split by \r\n)
  - badges (a collection of badges, split by \r\n)
- POST /api/v1/user
  - just like 'GET /api/v1/cadet/:username.json'
    - username (String)