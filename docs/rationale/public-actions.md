# Public Actions

We distinguish three types of public interactions with the SC:

- _View actions_: methods to query system state variables
- _User actions_: methods oriented to MoC's wider user base, allowing them to interact with Tokens and Investment instruments.
- _Process actions_: methods that allow the system to evolve under time and/or btc price rules
  All actions are performed directly to the `MoC` contract, although it usually channels the request to a more specific contract, working as a unified Proxy entry point.
