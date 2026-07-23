# Contributing to SpeciFit

Thank you for your interest in contributing to SpeciFit! Below you will find the upcoming features and tasks that need to be implemented. If you'd like to contribute, please follow the instructions and guidelines outlined below.

## 1. Exercises Database Integration

We need to build and integrate an extensive exercises database into the app.

### What to do
Download fitness exercises datasets from the provided sources and integrate them into the app's database.

### Where to get the data
Please use the following datasets:
- [Kaggle: Fitness Exercises Dataset (omarxadel)](https://www.kaggle.com/datasets/omarxadel/fitness-exercises-dataset)
- [Training.fit Exercises](https://training.fit/exercise/)
- [Kaggle: Fitness Exercises Dataset (exercisedb)](https://www.kaggle.com/datasets/exercisedb/fitness-exercises-dataset)

### How to do it
1. Extract and normalize the data from the sources above into a single consistent format.
2. Structure the data to include exercise names, instructions, target muscles, equipment needed, and media (images/videos).
3. Import this data into the app's local storage or backend database.
4. Ensure the app's UI is updated to query, filter, and display these exercises correctly.

---

## 2. Workouts Video Database Update

The home workout videos need to be categorized and served based on the user's gender. Male videos should focus on male fitness aspects, and female videos should focus on female fitness aspects.

### What to do
Update the existing JSON database to include and differentiate between male and female workout videos.

### Where to do it
File: `workouts_video_database.json`

### How to do it
1. Source appropriate workout videos for both males and females.
2. Update the `workouts_video_database.json` file.
3. Use the following specific naming conventions in the JSON structure:
   - **`HomeWorkoutVidsM`**: Use this key/prefix for videos meant for males.
   - **`F`**: Use this suffix/key for videos meant for females.
4. Update the app logic to read the user's gender profile and fetch the corresponding videos from the database.

---

## 3. AI-Powered Dynamic Meal Suggestions (Premium Feature)

Currently, the meal suggestions are hardcoded. We need to make this feature dynamic, personalized using AI, and gate it behind a premium subscription.

### What to do
Replace the hardcoded meal lists with an AI-driven system that generates personalized meal plans. This feature must be locked behind a one-time subscription purchase.

### Where to do it
- File: `meals_list_data.dart` (Current hardcoded logic location)
- Payment/Subscription modules
- UI screens for meal generation and paywall

### How to do it
1. **Premium Subscription**: Implement a paywall for a one-time subscription priced at **299**. This subscription unlocks the meal suggestion feature (and the premium chat feature).
2. **AI Integration**: Integrate an AI service (e.g., Gemini or OpenAI API) to generate personalized meal plans. 
3. **Dynamic Generation**: The AI must be prompted to generate meals based on the user's profile and must support the following dietary preferences:
   - Veg (Vegetarian)
   - Eggetarian
   - Non-Veg
4. **Refactoring**: In `meals_list_data.dart`, remove the hardcoded lists and wire up the UI to fetch data from the newly created AI generation service, but only if the user has purchased the subscription.

---

## 4. Live Agent Chat (Premium Feature)

We want to add a premium capability to the existing chat feature, allowing users to talk directly with a live agent.

### What to do
Add a "Talk to Live Agent" option within the chat interface, exclusively for premium users.

### Where to do it
- Chat UI components
- Chat routing/backend logic

### How to do it
1. Verify if the user has purchased the premium subscription (the same 299 subscription mentioned above).
2. If the user is a premium member, enable a "Talk to Live Agent" button or command in the chat interface.
3. Implement the logic to connect the user to a live agent queue.
4. If the user is not a premium member, this option should either be hidden or show a locked state that prompts them to upgrade.

---

### General Contribution Rules
- Create a new branch for your feature.
- Follow the existing code style and architecture.
- Test your changes thoroughly.
- Submit a clear and descriptive Pull Request (PR).
