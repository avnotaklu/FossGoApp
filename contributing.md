# Intro
The codebase should be fairly easy to understand. I have tried to make the code self-documenting.

However, this also means there are not many comments in the code. If you are studying the code, you can add comments as you go. PRs are welcome in this department.
I will be adding comments, whenever working on that section of the code.

It uses [best practices](https://dart.dev/effective-dart/style) given by the Dart team, so be sure to follow that.

It uses [provider](https://pub.dev/packages/provider) for state management.

It also uses [fpdart](https://pub.dev/packages/fpdart) for error handling. Particulary the `Either` and `TaskEither` types.

# Structure
Modules are divided on a per-screen basis; check out [./lib/modules](./lib/modules).

Core functionalities/reusable code are part of [./lib/core](./lib/core).

Reusable widgets are part of [./lib/widgets](./lib/widgets).

There are some tests written for core functionalities; check out [./test](./test). It would be great to see more work in testing.

# Do this
If you want to fix things or add features, open an issue first so we can discuss it.

If you have variants in mind, let me know that as well. I am looking to design some fun variants for Go and implement them into the server.

I haven't started with localizations yet.
I think they are very important for a good user experience, especially because many go players are from a wide variety of countries.
If you are fluent in languages other than English. Hit me up.
