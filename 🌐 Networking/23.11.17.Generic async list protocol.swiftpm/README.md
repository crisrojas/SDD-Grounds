#  Generic async list protocol

The goal of this playground is to came up with a reusable abstraction for async lists.

You usually have the same repetitive elements in such a list:

- A state
- A fetch function that retrieves data and sets state accordingly
- A view = f(State) (renders different UI depending on the state)

The idea is to reuse everything we can, so I can write less code.

Also, I'ven tested, but the solution purposed here could be used with an Observable instead of a local @State so we can share state among screens, should be relatively easy to implement.
