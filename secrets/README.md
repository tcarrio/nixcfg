# secrets

This directory maintains all secrets across the repository. It includes the `agenix` target users public keys as well as which `age` secret files should be configured for which targets. In this way, we can safely manage secrets in source control without exposing them.

All `.age` files are encrypted using `age` and committed to source control in their encrypted state.

> _This functionality is a work in progress and not yet fully implemented. As such, expect this to be changed and documented as development continues._