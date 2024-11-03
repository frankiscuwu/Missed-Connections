![Django](https://img.shields.io/badge/django-%23092E20.svg?style=for-the-badge&logo=django&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
![ChatGPT](https://img.shields.io/badge/chatGPT-74aa9c?style=for-the-badge&logo=openai&logoColor=white)
![Railway](https://img.shields.io/badge/Railway-131415?style=for-the-badge&logo=railway&logoColor=white)

<img src="Streetpass/Streetpass/Assets.xcassets/rainbow1.imageset/Orange%20Minimalist%20Travel%20App%20Business%20Logo%20(1).png" alt="Logo" width="300">

# Missed Connections 💫

*Missed Connections* is a unique social app inspired by the nostalgia of Nintendo StreetPass. Designed to enhance your everyday encounters, it tracks your location throughout the day, tracking where you encounter like-minded individuals. At the end of each day, our algorithm matches you with those you passed who share your interests, allowing you to discover potential friendships and connections that you may have missed in real life.

## Features ✨
- Geo-tracking
- AI-powered matching
- more?

## How it Works 🛠️
- Using Swift, we get your location periodically throughout the day. These calls are made to our Django backend server, which stores user information

## Tech Stack 🤓
- **Swift**, for front-end development on iOS
- **Django** and **Python**, which manages API calls and matches people with our algorithm powered by **OpenAI**
- **PostgreSQL**, for storing and efficiently querying user data
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

