<h1>API Reference:</h1>

## /post_location/
- POST: Takes in “lat” and “long”
- The user must be logged in

## /get_users/
- GET: Gives the suggested people for a logged-in user
- The user must be logged in

## /post_friends/
- POST: Takes a "friend_username"
- Makes you guys friends
- The user must be logged in

## /post_profile/
- POST: Takes in "interest1", "interest2", "interest3", "links", "school", "major", "hometown"
- Updates or creates a profile for a logged-in user
- The user must be logged in

<h2>Authentication Features</h2>

## /login/
- POST: Takes in “username” and “password”
- Logs in user, user must be created with /signup

## /logout/
- GET: Takes nothing
- Logs out user

## /signup/
- POST: Takes in “username” and “password”
- Creates a new user in the DB

