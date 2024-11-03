![Django](https://img.shields.io/badge/django-%23092E20.svg?style=for-the-badge&logo=django&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
![ChatGPT](https://img.shields.io/badge/chatGPT-74aa9c?style=for-the-badge&logo=openai&logoColor=white)
![Railway](https://img.shields.io/badge/Railway-131415?style=for-the-badge&logo=railway&logoColor=white)

<img src="Streetpass/Streetpass/Assets.xcassets/rainbow1.imageset/Orange%20Minimalist%20Travel%20App%20Business%20Logo%20(1).png" alt="Logo" width="300">

# Missed Connections 💫

*Missed Connections* is a unique **full-stack** iOS ocial app inspired by the nostalgia of Nintendo StreetPass. Designed to enhance your everyday encounters, it tracks your location throughout the day, tracking where you encounter like-minded individuals. At the end of each day, our algorithm matches you with those you passed who share your interests, allowing you to discover potential friendships and connections that you may have missed in real life.

## Features ✨
- Geo-tracking: Using Apple's *CoreLocation* framework, we log a user's location throughout the day. 
- AI-powered matching: The matching system is done by *ChatGPT* which ranks the similarity between our client and people the client has ran into. If they share high similarites, we notify the respective users that they shared a *misconnection*.
- Full User Authentication: Leveraging Django's built-in authentication library, we allow users to signup, create a profile, login, and logout of the app

## How it Works 🛠️
- Using Swift, we get your location periodically throughout the day. These calls are made to our Django backend server, which stores your user information. The server then finds all other users that were aproximately close to you. Then we utilize ChatGPT to test the similarity of interests and background between you and the people you were close to. At the end of the day, you can find three people you walked by and share very similar interest. We share this information to the frontend Swift server. You can then further connect with these people by adding them as friends on the app. 

## Tech Stack 🤓
- **Swift**, for front-end development on iOS and majorly used Apple's *Foundation* framework, *CoreLocation* framework, and *MapKit*
- **Django** and **Python**, which manages API calls and matches people with our algorithm powered by **OpenAI**
- **PostgreSQL**, for storing and efficiently querying location, friendship, and user data
- **Railway**, for hosting our PostgreSQL DB

<h1>API Reference: 📖</h1>

## /post_location/
- POST: Takes in “lat” and “long”
- The user must be logged in

## /get_users/
- GET: Gives the suggested people for a logged-in user
- The user must be logged in

## /get_friends/
- GET: Gives list of your friends and their profile info
- The user must be logged in


## /post_friends/
- POST: Takes a "username"
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

