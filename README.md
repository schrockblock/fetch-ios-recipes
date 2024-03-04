# Welcome!
Here's a quick guide to this codebase, and some reflections on choices I made while preparing this exercise.

This is a SwiftUI app that uses TCA for state management. I've opted to use the `observation-beta` branch thereof, since it makes things significantly more ergonomic and readable.

I've organized the codebase by function (eg, a folder for models, a folder for views, and so on), rather than by feature (eg, a folder for meal list related models/views/what-have-you, a folder for detail view related models/views/what-have-you, and so on). I prefer this method of organization because otherwise I find it difficult to decide where to put code that is used over and over throughout the app.

I used SPM for dependencies, which is perhaps obvious with the choice of TCA.

I did NOT add this project to my CI – simply because it costs money, and I don't want to do that on a toy project.

Areas of interest for you to check out:
- This is pretty well tested for the relatively low number of tests (I adhere to a "test behavior not implementation" philosophy), and verifies the parameters of the exercise (eg, alphabetic desserts, navigating to details, etc)
- There's some heavy lifting in the model layer to wrestle the API into a more Swift-friendly format (and satisfy the requirements). It's not explicitly tested because our reducer tests verify the behavior we want without us needing to know how or where the behavior is enabled.

## Choices
1. I chose to keep this fairly brief – I considered adding code to switch between categories, search for recipes, and even making versions in UIKit and objc, but then I remembered what it's like reviewing take home exercises. For your sake, I've kept it short so you can look through it without too much trouble. The only extra I added was making the list of recipes filterable.
2. I used a networking framework that I maintain in order to speed things up. It's a relatively lightweight wrapper on top of URLSession though, it just separates concerns a bit better in my opinion. Read about it on [my website](https://elliotschrock.com/2020/07/16/what-makes-a-good-network-layer/) or check out [the source](https://github.com/LithoByte/funnet).
3. I used TCA over MVVM or another pattern because I wanted to make sure this was well tested, and I've yet to find anything better at keeping SwiftUI code testable than TCA. Also I've worked with Brandon and Stephen, so I have a soft spot for it.
4. I generally use `git-flow` as a branching model, so I've added a develop branch to this repo. That said, I've had some frustration with it as a model for release management, so I'm happy to work under a different framework.
